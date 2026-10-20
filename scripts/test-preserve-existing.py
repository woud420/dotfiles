#!/usr/bin/env python3
"""Exercise the preserving installer against disposable sources and homes."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import stat
import subprocess
import sys
import tempfile

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
GIT = shutil.which('git')
TARGETS = ['.agents/skills', '.codex/skills', '.claude/skills']


def snapshot(root):
    result = {}
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in dirs + files:
            p = Path(directory) / name
            relative = str(p.relative_to(root))
            if p.is_symlink():
                result[relative] = ('link', os.readlink(p))
            elif p.is_file():
                result[relative] = ('file', hashlib.sha256(p.read_bytes()).hexdigest(),
                                    stat.S_IMODE(p.stat().st_mode), p.stat().st_mtime_ns)
    return result


def write(path, content, executable=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    if executable:
        path.chmod(0o755)


with tempfile.TemporaryDirectory(prefix='dotfiles-preserve-test.') as temporary:
    temp = Path(temporary)
    source = temp / 'source'
    source.mkdir()
    shutil.copy2(ROOT / 'install.sh', source / 'install.sh')
    for directory in ['common/themes', 'darwin']:
        shutil.copytree(ROOT / directory, source / directory)
    (source / 'scripts').mkdir(exist_ok=True)
    for name in ['sudo-askpass.sh', 'vim-plug-update.sh']:
        shutil.copy2(ROOT / 'scripts' / name, source / 'scripts' / name)
    skills = source / 'private/skills'
    entries = [dict(name=name, path=name + '/SKILL.md', status=status)
               for name, status in [('tool-active', 'active'), ('tool-maintenance', 'maintenance'), ('tool-candidate', 'candidate')]]
    for entry in entries:
        write(skills / entry['path'], '---\nname: ' + entry['name'] + '\n---\nnew skill revision\n')
    write(skills / 'manifest.json', json.dumps({'skills': entries}))
    write(skills / 'tool-active/scripts/check.sh', '#!/bin/sh\nexit 0\n', executable=True)
    subprocess.run([GIT, 'init', '-q', str(skills)], check=True)
    subprocess.run([GIT, '-C', str(skills), 'add', '.'], check=True)
    write(skills / 'tool-active/untracked.txt', 'must not install\n')
    stubs = temp / 'bin'
    stubs.mkdir()
    calls = temp / 'calls.log'
    blocked = ['brew', 'sudo', 'apt-get', 'pacman', 'npm', 'nvim', 'vim', 'curl', 'launchctl', 'systemctl', 'chsh']
    for command in blocked:
        write(stubs / command, '#!/bin/sh\nprintf "%s\\n" "$0 $*" >> "$CALL_LOG"\nexit 99\n', executable=True)
    write(stubs / 'python3', '#!/bin/sh\nexec ' + "'" + sys.executable.replace("'", "'\\''") + "'" + ' "$@"\n', executable=True)
    results = []

    def invoke(home, *args, expected=0, skip_skills=False):
        env = os.environ.copy()
        env.update(HOME=str(home), PATH=str(stubs) + ':/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
                   DOTFILES_SKIP_PRIVATE_SKILLS='1' if skip_skills else '0', CI='', KITTY_PID='',
                   CALL_LOG=str(calls), DOTFILES_BACKUP_DIR=str(temp / (home.name + '-backup')),
                   DOTFILES_FULL_INSTALL='1')
        env['GIT_CONFIG_GLOBAL'] = str(home / '.gitconfig')
        env['GIT_CONFIG_NOSYSTEM'] = '1'
        p = subprocess.run(['/bin/bash', str(source / 'install.sh'), *args], env=env,
                           cwd=source, text=True, capture_output=True, timeout=45)
        assert (p.returncode == 0) == (expected == 0), p.stdout + p.stderr
        results.append({'home': home.name, 'args': args, 'exit': p.returncode})
        return p

    def seed(name, custom_kitty=False):
        home = temp / name
        home.mkdir()
        for path in ['.zshrc', '.bashrc', '.bash_profile', '.gnu_aliases', '.dircolors', '.gitconfig',
                     '.ssh/config', '.vim/vimrc', '.vim/plugins.vim', '.vim/coc-settings.json',
                     '.config/nvim/init.vim', '.config/nvim/coc-settings.json', '.config/shell-functions/editor.sh',
                     '.config/git/hooks/pre-commit', 'AGENTS.md', 'MACHINE.md', '.claude/CLAUDE.md']:
            write(home / path, 'keep current ' + path + '\n')
        write(home / '.gitconfig', '[alias]\n  st = status\n[credential "https://github.com"]\n  helper = existing-helper\n')
        kitty = home / '.config/kitty'
        kitty.mkdir(parents=True)
        shutil.copy2(source / 'darwin/kitty.conf', kitty / 'kitty.conf')
        shutil.copy2(source / 'common/themes/current-theme.conf', kitty / 'current-theme.conf')
        if custom_kitty:
            with (kitty / 'kitty.conf').open('a') as f:
                f.write('\ninclude *.conf\n')
        for target in TARGETS:
            write(home / target / 'tool-active/SKILL.md', 'old skill revision\n')
            write(home / target / 'tool-active/local-note.txt', 'keep target-only file\n')
            write(home / target / 'target-only/SKILL.md', 'keep target-only skill\n')
            write(home / target / 'tool-candidate/SKILL.md', 'keep installed candidate\n')
        return home

    home = seed('main')
    before = snapshot(home)
    invoke(home, '--preserve-existing')
    after = snapshot(home)
    mutable = {target + '/' + name + '/SKILL.md' for target in TARGETS
               for name in ['tool-active', 'tool-candidate']}
    for path, original in before.items():
        if path not in mutable:
            assert after[path] == original, path
    for target in TARGETS:
        for path in ['tool-active/SKILL.md', 'tool-active/scripts/check.sh', 'tool-maintenance/SKILL.md', 'tool-candidate/SKILL.md']:
            assert (home / target / path).read_bytes() == (skills / path).read_bytes()
        assert not (home / target / 'tool-active/untracked.txt').exists()
        backup = temp / 'main-backup/files' / target / 'tool-active/SKILL.md'
        assert backup.read_text() == 'old skill revision\n'
    for name in ['sudo-askpass', 'vim-plug-update']:
        assert (home / '.local/bin' / name).read_bytes() == (source / 'scripts' / (name + '.sh')).read_bytes()
        assert os.access(home / '.local/bin' / name, os.X_OK)
    assert not (home / 'Library/LaunchAgents').exists()
    assert not (home / '.config/systemd').exists()
    assert not (home / '.ssh/config.dotfiles').exists()
    assert not (home / '.config/shell-functions/sudo.sh').exists()
    expected_additions = {target + '/' + path for target in TARGETS
                          for path in ['tool-active/scripts/check.sh', 'tool-maintenance/SKILL.md']}
    expected_additions |= {'.local/bin/sudo-askpass', '.local/bin/vim-plug-update'}
    if sys.platform == 'darwin':
        expected_additions |= {'.config/kitty/' + p.name for p in (source / 'common/themes').glob('*.conf') if p.name != 'current-theme.conf'}
    assert set(after) - set(before) == expected_additions
    invoke(home, '--preserve-existing')
    assert snapshot(home) == after, 'second install rewrote existing files'

    uninstalled = seed('uninstalled-candidate')
    shutil.rmtree(uninstalled / '.codex/skills/tool-candidate')
    invoke(uninstalled, '--preserve-existing')
    assert not (uninstalled / '.codex/skills/tool-candidate').exists()

    dry = seed('dry')
    before_dry = snapshot(dry)
    invoke(dry, '--preserve-existing', '--dry-run')
    assert snapshot(dry) == before_dry
    assert not (temp / 'dry-backup').exists()
    for flag in ['--check', '--backup-only', '--doctor', '--minimal']:
        invoke(dry, '--preserve-existing', flag, expected=1)
        assert snapshot(dry) == before_dry

    custom = seed('custom', custom_kitty=True)
    invoke(custom, '--preserve-existing')
    assert sorted(p.name for p in (custom / '.config/kitty').iterdir()) == ['current-theme.conf', 'kitty.conf']

    collisions = seed('collisions')
    write(stubs / 'sudo-askpass', '#!/bin/sh\nexit 99\n', executable=True)
    write(stubs / 'vim-plug-update', '#!/bin/sh\nexit 99\n', executable=True)
    invoke(collisions, '--preserve-existing')
    assert not (collisions / '.local/bin').exists()
    (stubs / 'sudo-askpass').unlink()
    (stubs / 'vim-plug-update').unlink()

    links = seed('links')
    outside = temp / 'outside'
    outside.mkdir()
    (links / '.local').mkdir()
    (links / '.local/bin').symlink_to(outside, target_is_directory=True)
    invoke(links, '--preserve-existing')
    assert not list(outside.iterdir())
    assert (links / '.local/bin').is_symlink()

    bad = seed('bad-skill-target')
    shutil.rmtree(bad / '.claude/skills')
    (bad / '.claude/skills').symlink_to(outside, target_is_directory=True)
    before_bad = snapshot(bad)
    invoke(bad, '--preserve-existing', expected=1)
    assert snapshot(bad) == before_bad and not list(outside.iterdir())

    invalid = seed('invalid-manifest')
    original = (skills / 'manifest.json').read_bytes()
    write(skills / 'manifest.json', json.dumps({'skills': entries + [dict(name='missing', path='missing/SKILL.md', status='active')]}))
    before_invalid = snapshot(invalid)
    invoke(invalid, '--preserve-existing', expected=1)
    assert snapshot(invalid) == before_invalid
    (skills / 'manifest.json').write_bytes(original)

    skipped = seed('skip-skills')
    before_skipped = snapshot(skipped)
    invoke(skipped, '--preserve-existing', skip_skills=True)
    for path, value in before_skipped.items():
        assert snapshot(skipped)[path] == value

    empty = temp / 'empty'
    empty.mkdir()
    invoke(empty, '--preserve-existing', skip_skills=True)
    assert set(snapshot(empty)) == {'.local/bin/sudo-askpass', '.local/bin/vim-plug-update'}

    obstructed = seed('non-directory-parent')
    write(obstructed / '.local', 'keep this non-directory parent\n')
    invoke(obstructed, '--preserve-existing', skip_skills=True)
    assert (obstructed / '.local').read_text() == 'keep this non-directory parent\n'
    assert not calls.exists(), calls.read_text() if calls.exists() else ''
    print('Preserving installer checks passed: active configs, skill updates/backups across three harnesses,')
    print('target-only retention, no plugin/package/service calls, idempotence, dry-run, flag validation,')
    print('custom theme protection, command collisions, symlinks, and invalid skill manifests.')
    artifact = os.environ.get('DOTFILES_TEST_REPORT')
    if artifact:
        Path(artifact).write_text(json.dumps({'passed': True, 'cases': results}, indent=2) + '\n')
