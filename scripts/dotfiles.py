#!/usr/bin/env python3
"""Copy-based dotfiles installer, backup, drift checker, and doctor."""

from __future__ import annotations

import argparse
import datetime as dt
import filecmp
import hashlib
import json
import os
import platform
import shutil
import subprocess
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
HOME = Path.home()
STATE_DIR = HOME / ".local" / "share" / "dotfiles"
MANIFEST = STATE_DIR / "install-manifest.json"


@dataclass(frozen=True)
class ManagedFile:
    source: Path
    target: Path
    label: str


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(REPO))
    except ValueError:
        return str(path)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_machine(name: str | None) -> tuple[str, dict]:
    machine = name or platform.node().split(".")[0]
    path = REPO / "machines" / machine / "machine.toml"
    if not path.exists():
        raise SystemExit(f"No machine profile found at {rel(path)}")
    with path.open("rb") as handle:
        return machine, tomllib.load(handle)


def add_file(entries: list[ManagedFile], source: str, target: str, label: str) -> None:
    src = REPO / source
    if not src.exists():
        raise SystemExit(f"Managed source is missing: {rel(src)}")
    entries.append(ManagedFile(src, Path(target).expanduser(), label))


def add_glob(entries: list[ManagedFile], source_glob: str, target_dir: str, label: str) -> None:
    matches = sorted(REPO.glob(source_glob))
    if not matches:
        raise SystemExit(f"Managed source glob matched nothing: {source_glob}")
    dest = Path(target_dir).expanduser()
    for src in matches:
        if src.is_file():
            entries.append(ManagedFile(src, dest / src.name, label))


def managed_files(machine: dict) -> list[ManagedFile]:
    os_name = machine.get("os")
    entries: list[ManagedFile] = []

    add_file(entries, "common/shell/.zshrc", "~/.zshrc", "shell")
    add_file(entries, "common/shell/.bashrc", "~/.bashrc", "shell")
    add_file(entries, "common/shell/.bash_profile", "~/.bash_profile", "shell")
    add_file(entries, "common/shell/.gnu_aliases", "~/.gnu_aliases", "shell")
    add_file(entries, "common/shell/.dircolors", "~/.dircolors", "shell")

    add_file(entries, "common/git/.gitconfig", "~/.gitconfig", "git")
    add_file(entries, "common/git/.gitignore_global", "~/.config/git/ignore", "git")

    add_glob(entries, "common/shell-functions/*.sh", "~/.config/shell-functions", "shell-functions")

    if os_name == "darwin":
        add_file(entries, "darwin/kitty.conf", "~/.config/kitty/kitty.conf", "kitty")
    else:
        add_file(entries, "linux/common/kitty.conf", "~/.config/kitty/kitty.conf", "kitty")
    add_glob(entries, "common/themes/*.conf", "~/.config/kitty", "kitty")

    add_file(entries, "common/htop/htoprc", "~/.config/htop/htoprc", "htop")

    add_file(entries, ".vim/vimrc", "~/.vim/vimrc", "vim")
    add_file(entries, ".vim/plugins.vim", "~/.vim/plugins.vim", "vim")
    add_file(entries, ".vim/mappings.vim", "~/.vim/mappings.vim", "vim")
    add_file(entries, ".vim/settings.vim", "~/.vim/settings.vim", "vim")
    add_file(entries, ".vim/coc-settings.json", "~/.vim/coc-settings.json", "vim")
    add_glob(entries, ".vim/settings/*.vim", "~/.vim/settings", "vim")

    add_file(entries, "common/nvim/init.vim", "~/.config/nvim/init.vim", "nvim")
    add_file(entries, "common/bin/dotfiles", "~/.local/bin/dotfiles", "bin")

    return entries


def backup_root() -> Path:
    stamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    return HOME / ".dotfiles-backups" / stamp


def backup_target(target: Path, root: Path, *, dry_run: bool) -> None:
    if not target.exists() and not target.is_symlink():
        return
    try:
        relative = target.relative_to(HOME)
    except ValueError:
        relative = Path(target.name)
    dest = root / relative
    print(f"backup {target} -> {dest}")
    if dry_run:
        return
    dest.parent.mkdir(parents=True, exist_ok=True)
    if target.is_symlink():
        link_target = os.readlink(target)
        symlink_record = dest.with_name(f"{dest.name}.symlink")
        symlink_record.write_text(f"symlink -> {link_target}\n", encoding="utf-8")
        if target.exists() and target.is_file():
            shutil.copy2(target, dest)
    else:
        shutil.copy2(target, dest)


def command_backup(args: argparse.Namespace) -> int:
    _, machine = load_machine(args.machine)
    root = Path(args.output).expanduser() if args.output else backup_root()
    for entry in managed_files(machine):
        backup_target(entry.target, root, dry_run=args.dry_run)
    if not args.dry_run:
        print(f"backup saved to {root}")
    return 0


def copy_entry(entry: ManagedFile, backup_dir: Path, *, dry_run: bool) -> dict:
    changed = True
    if entry.target.is_symlink():
        changed = True
    elif entry.target.exists() and entry.target.is_file():
        changed = not filecmp.cmp(entry.source, entry.target, shallow=False)

    action = "copy"
    if not changed:
        action = "unchanged"
    print(f"{action} {rel(entry.source)} -> {entry.target}")

    if dry_run or not changed:
        return manifest_entry(entry, copied=not dry_run and not changed)

    backup_target(entry.target, backup_dir, dry_run=False)
    entry.target.parent.mkdir(parents=True, exist_ok=True)
    if entry.target.is_symlink():
        entry.target.unlink()
    shutil.copy2(entry.source, entry.target)
    return manifest_entry(entry, copied=True)


def manifest_entry(entry: ManagedFile, *, copied: bool) -> dict:
    data = {
        "source": rel(entry.source),
        "target": str(entry.target),
        "label": entry.label,
        "source_sha256": sha256(entry.source),
        "copied": copied,
    }
    if entry.target.exists() and entry.target.is_file():
        data["target_sha256"] = sha256(entry.target)
    return data


def command_install(args: argparse.Namespace) -> int:
    machine_name, machine = load_machine(args.machine)
    entries = managed_files(machine)
    backup_dir = backup_root()
    manifest = {
        "machine": machine_name,
        "installed_at": dt.datetime.now(dt.UTC).isoformat(),
        "repo": str(REPO),
        "files": [],
    }
    for entry in entries:
        manifest["files"].append(copy_entry(entry, backup_dir, dry_run=args.dry_run))

    if args.dry_run:
        print("dry run only; no files copied")
        return 0

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"manifest written to {MANIFEST}")
    return 0


def command_diff_live(args: argparse.Namespace) -> int:
    _, machine = load_machine(args.machine)
    changed = 0
    missing = 0
    for entry in managed_files(machine):
        if not entry.target.exists():
            print(f"missing {entry.target} <- {rel(entry.source)}")
            missing += 1
        elif entry.target.is_symlink():
            print(f"symlink {entry.target} <- {rel(entry.source)}")
            changed += 1
        elif not filecmp.cmp(entry.source, entry.target, shallow=False):
            print(f"changed {entry.target} <- {rel(entry.source)}")
            changed += 1
    if changed or missing:
        print(f"{changed} changed, {missing} missing")
        return 1
    print("managed files match repo sources")
    return 0


def command_manifest(args: argparse.Namespace) -> int:
    if not MANIFEST.exists():
        print(f"no manifest found at {MANIFEST}")
        return 1
    print(MANIFEST.read_text(encoding="utf-8"), end="")
    return 0


def has_command(command: str) -> bool:
    return shutil.which(command) is not None


def command_doctor(args: argparse.Namespace) -> int:
    machine_name, machine = load_machine(args.machine)
    required = ["python3", "git", "kitty", "rg", "fzf"]
    preferred = [machine.get("shell", "zsh"), machine.get("editor", "nvim"), "op"]
    if machine.get("sshd"):
        preferred.append("sshd")

    print(f"machine: {machine_name}")
    print(f"profile: {machine.get('profile', 'unknown')}")
    failures = 0

    for command in required:
        status = "ok" if has_command(command) else "missing"
        print(f"required {command}: {status}")
        failures += status == "missing"

    for command in preferred:
        status = "ok" if has_command(command) else "missing"
        print(f"preferred {command}: {status}")

    if failures:
        print(f"doctor found {failures} missing required tool(s)")
        return 1
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="dotfiles")
    parser.add_argument("--machine", help="machine profile name; defaults to hostname")
    sub = parser.add_subparsers(dest="command", required=True)

    backup = sub.add_parser("backup", help="backup managed live files")
    backup.add_argument("--dry-run", action="store_true")
    backup.add_argument("--output", help="backup directory")
    backup.set_defaults(func=command_backup)

    install = sub.add_parser("install", help="copy managed files into place")
    install.add_argument("--dry-run", action="store_true")
    install.set_defaults(func=command_install)

    diff_live = sub.add_parser("diff-live", help="compare live managed files to repo")
    diff_live.set_defaults(func=command_diff_live)

    manifest = sub.add_parser("manifest", help="print last install manifest")
    manifest.set_defaults(func=command_manifest)

    doctor = sub.add_parser("doctor", help="check this machine for expected tools")
    doctor.set_defaults(func=command_doctor)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
