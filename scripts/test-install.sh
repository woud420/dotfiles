#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install-test.XXXXXX")"
TEST_HOME="$TMP_DIR/home"
STUB_DIR="$TMP_DIR/bin"
STUB_LOG="$TMP_DIR/stubs.log"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TEST_HOME" "$STUB_DIR"

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

HOME="$TEST_HOME" \
PATH="$STUB_DIR:$PATH" \
DOTFILES_INSTALL_TEST_LOG="$STUB_LOG" \
    "$ROOT_DIR/install.sh" --no-packages > "$TMP_DIR/install.log"

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

AUDIT_LOG="$(find "$TEST_HOME" -path '*/.dotfiles-backup-*/install-audit.tsv' -print -quit)"
[[ -n "$AUDIT_LOG" ]] || fail "audit log was not created"
grep -q $'\tcopy\t' "$AUDIT_LOG" || fail "audit log has no copy action"
! grep -q $'\tlink\t' "$AUDIT_LOG" || fail "audit log must not contain link actions"
grep -q "$ROOT_DIR/common/nvim/init.vim" "$AUDIT_LOG" || fail "audit log does not include neovim init"

# vim step defers to nvim when nvim exists (stubbed here), so no vim invocation
! grep -q '^vim ' "$STUB_LOG" || fail "vim should not be invoked when nvim is present"
grep -q '^nvim --headless +PlugInstall +qall$' "$STUB_LOG" || fail "nvim plugin install was not invoked"

printf 'Installer test passed.\n'
