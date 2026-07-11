#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install-test.XXXXXX")"
TEST_HOME="$TMP_DIR/home"
DRY_HOME="$TMP_DIR/dry-home"
STUB_DIR="$TMP_DIR/bin"
STUB_LOG="$TMP_DIR/stubs.log"
INSTALL_BACKUP="$TMP_DIR/install-backup"
MANUAL_BACKUP="$TMP_DIR/manual-backup"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p \
    "$TEST_HOME/.mozilla/firefox/test.default/chrome" \
    "$TEST_HOME/.ssh" \
    "$DRY_HOME" \
    "$STUB_DIR"

printf 'pre-install bashrc\n' > "$TEST_HOME/.bashrc"
cat > "$TEST_HOME/.ssh/config" <<'SSH_CONFIG'
Host github.com
  User git
  IdentityFile ~/.ssh/github_ed25519
SSH_CONFIG
cat > "$TEST_HOME/.mozilla/firefox/profiles.ini" <<'PROFILE'
[InstallTest]
Default=test.default
Locked=1

[Profile0]
Name=default
IsRelative=1
Path=test.default
Default=1
PROFILE

cat > "$STUB_DIR/vim" <<'STUB'
#!/usr/bin/env bash
printf 'vim %s\n' "$*" >> "${DOTFILES_INSTALL_TEST_LOG:?}"
exit 0
STUB

cat > "$STUB_DIR/nvim" <<'STUB'
#!/usr/bin/env bash
printf 'nvim %s\n' "$*" >> "${DOTFILES_INSTALL_TEST_LOG:?}"
exit 0
STUB

chmod +x "$STUB_DIR/vim" "$STUB_DIR/nvim"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_regular_copy() {
    local path="$1"
    local expected_source="$2"
    [[ -f "$path" ]] || fail "$path is not a regular file"
    [[ ! -L "$path" ]] || fail "$path must not be a symlink"
    cmp -s "$path" "$expected_source" || fail "$path differs from $expected_source"
}

assert_file() {
    local path="$1"
    [[ -f "$path" ]] || fail "$path is not a file"
}

run_installer() {
    local home="$1"
    local backup_dir="$2"
    shift 2

    HOME="$home" \
    PATH="$STUB_DIR:$PATH" \
    KITTY_PID='' \
    DOTFILES_SKIP_PRIVATE_SKILLS="${DOTFILES_SKIP_PRIVATE_SKILLS:-1}" \
    DOTFILES_INSTALL_TEST_LOG="$STUB_LOG" \
    DOTFILES_BACKUP_DIR="$backup_dir" \
    DOTFILES_FULL_INSTALL=1 \
        "$ROOT_DIR/install.sh" "$@"
}

run_installer "$TEST_HOME" "$INSTALL_BACKUP" --no-packages > "$TMP_DIR/install.log"

assert_regular_copy "$TEST_HOME/.bashrc" "$ROOT_DIR/common/shell/.bashrc"
assert_regular_copy "$TEST_HOME/.zshrc" "$ROOT_DIR/common/shell/.zshrc"
assert_regular_copy "$TEST_HOME/.gitconfig" "$ROOT_DIR/common/git/.gitconfig"
assert_regular_copy "$TEST_HOME/.vim/vimrc" "$ROOT_DIR/.vim/vimrc"
assert_regular_copy "$TEST_HOME/.config/nvim/init.vim" "$ROOT_DIR/common/nvim/init.vim"
assert_regular_copy "$TEST_HOME/.config/nvim/coc-settings.json" "$ROOT_DIR/.vim/coc-settings.json"

assert_file "$TEST_HOME/.gnu_aliases"
assert_file "$TEST_HOME/.dircolors"
assert_file "$TEST_HOME/.config/kitty/kitty.conf"
assert_file "$TEST_HOME/.config/shell-functions/git.sh"
assert_regular_copy "$TEST_HOME/.config/shell-functions/editor.sh" "$ROOT_DIR/common/shell-functions/editor.sh"
assert_regular_copy "$TEST_HOME/.config/shell-functions/which.sh" "$ROOT_DIR/common/shell-functions/which.sh"
assert_regular_copy "$TEST_HOME/.ssh/config.dotfiles" "$ROOT_DIR/common/ssh/config"
grep -q 'Include ~/.ssh/config.dotfiles' "$TEST_HOME/.ssh/config" || fail "shared SSH include is missing"
grep -q 'IdentityFile ~/.ssh/github_ed25519' "$TEST_HOME/.ssh/config" || fail "machine-local SSH identity was lost"
! grep -Eq '^[[:space:]]*IdentityFile[[:space:]]' "$TEST_HOME/.ssh/config.dotfiles" \
    || fail "shared SSH config must not select a machine-specific identity"

if [[ "${DOTFILES_SKIP_PRIVATE_SKILLS:-1}" == "0" ]]; then
    assert_regular_copy "$TEST_HOME/.agents/skills/autoresearch/SKILL.md" \
        "$ROOT_DIR/private/skills/autoresearch/SKILL.md"
    assert_regular_copy "$TEST_HOME/.agents/skills/skillpack-sync/SKILL.md" \
        "$ROOT_DIR/private/skills/skillpack-sync/SKILL.md"
    [[ ! -e "$TEST_HOME/.agents/skills/archive-triage" ]] \
        || fail "candidate private skill was installed"
fi

AUDIT_LOG="$INSTALL_BACKUP/install-audit.tsv"
[[ -f "$AUDIT_LOG" ]] || fail "audit log was not created"
grep -q $'\tcopy\t' "$AUDIT_LOG" || fail "audit log has no copy action"
! grep -q $'\tlink\t' "$AUDIT_LOG" || fail "audit log must not contain link actions"
grep -q "$ROOT_DIR/common/nvim/init.vim" "$AUDIT_LOG" || fail "audit log does not include neovim init"
grep -q '^pre-install bashrc$' "$INSTALL_BACKUP/files/.bashrc" || fail "pre-install bashrc was not backed up"
grep -q 'IdentityFile ~/.ssh/github_ed25519' "$INSTALL_BACKUP/files/.ssh/config" \
    || fail "machine-local SSH config was not backed up"

if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ "${ID,,}" == "arch" ]]; then
        assert_regular_copy "$TEST_HOME/.mozilla/firefox/test.default/user.js" "$ROOT_DIR/linux/arch/firefox/user.js"
        assert_regular_copy "$TEST_HOME/.mozilla/firefox/test.default/chrome/userChrome.css" "$ROOT_DIR/linux/arch/firefox/chrome/userChrome.css"
        assert_regular_copy "$TEST_HOME/.mozilla/firefox/test.default/chrome/userContent.css" "$ROOT_DIR/linux/arch/firefox/chrome/userContent.css"
    fi
fi

if ! run_installer "$TEST_HOME" "$INSTALL_BACKUP" --check > "$TMP_DIR/check-clean.log" 2>&1; then
    cat "$TMP_DIR/check-clean.log" >&2
    fail "--check rejected a clean install"
fi

printf 'locally changed zshrc\n' > "$TEST_HOME/.zshrc"
if run_installer "$TEST_HOME" "$INSTALL_BACKUP" --check > "$TMP_DIR/check-drift.log" 2>&1; then
    fail "--check did not detect a changed zshrc"
fi

run_installer "$TEST_HOME" "$MANUAL_BACKUP" --backup-only > "$TMP_DIR/backup.log"
grep -q '^locally changed zshrc$' "$MANUAL_BACKUP/files/.zshrc" || fail "--backup-only did not preserve live drift"
grep -q '^locally changed zshrc$' "$TEST_HOME/.zshrc" || fail "--backup-only changed the live file"

cp "$ROOT_DIR/common/shell/.zshrc" "$TEST_HOME/.zshrc"
if ! run_installer "$TEST_HOME" "$INSTALL_BACKUP" --check > "$TMP_DIR/check-restored.log" 2>&1; then
    cat "$TMP_DIR/check-restored.log" >&2
    fail "--check rejected the restored install"
fi

run_installer "$DRY_HOME" "$TMP_DIR/dry-backup" --dry-run --no-packages > "$TMP_DIR/dry-run.log"
[[ -z "$(find "$DRY_HOME" -mindepth 1 -print -quit)" ]] || fail "--dry-run changed HOME"
[[ ! -e "$TMP_DIR/dry-backup" ]] || fail "--dry-run created a backup directory"

# vim step defers to nvim when nvim exists (stubbed here), so no vim invocation
! grep -q '^vim ' "$STUB_LOG" || fail "vim should not be invoked when nvim is present"
grep -q '^nvim --headless +PlugInstall +qall$' "$STUB_LOG" || fail "nvim plugin install was not invoked"

printf 'Installer test passed.\n'
