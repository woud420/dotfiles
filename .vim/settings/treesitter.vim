" ===== Neovim Tree-sitter Configuration =====
" Phase 1 keeps Vimscript as the main configuration language while adding
" Neovim's parser-based highlighting where available.

if !has('nvim')
  finish
endif

lua << EOF
local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  return
end

configs.setup({
  ensure_installed = {
    "bash",
    "css",
    "dockerfile",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "python",
    "rust",
    "terraform",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})
EOF
