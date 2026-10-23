" ===== Neovim Tree-sitter Configuration =====
" nvim-treesitter's `main` branch is a thin parser and query manager: it no
" longer ships `nvim-treesitter.configs` or `ensure_installed`, and
" highlighting / indentation are enabled through Neovim's own vim.treesitter
" API. Requirements (`:checkhealth nvim-treesitter`): Neovim 0.12+, tar, curl,
" a C compiler, and tree-sitter-cli >= 0.26 (pacman: tree-sitter-cli,
" brew: tree-sitter-cli). Without the CLI this file stays inert and the regex
" syntax files from vim-polyglot keep highlighting.

if !has('nvim')
  finish
endif

lua << EOF
local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  return
end

-- Parsers built on first start; already-installed ones are skipped. The weekly
-- vim-plug-update job runs the synchronous update() so parsers track the
-- plugin revision, and `:TSUpdate` does the same by hand.
local ensure_installed = {
  "bash", "css", "dockerfile", "go", "html", "javascript", "json", "lua",
  "markdown", "markdown_inline", "python", "rust", "terraform", "toml", "tsx",
  "typescript", "vim", "vimdoc", "yaml",
}

if vim.fn.executable("tree-sitter") == 1 then
  ts.install(ensure_installed)
end

-- Tree-sitter indentation is still experimental upstream and misjudges Python
-- (dedent after return, continuation lines) and YAML nesting. Those two keep
-- Vim's built-in indent scripts, which is also what Vim uses on the laptop.
local builtin_indent = { python = true, yaml = true }

-- Highlight and indent with tree-sitter whenever a parser exists for the
-- buffer's filetype. vim.treesitter.start() disables regex syntax for that
-- buffer, matching the old `additional_vim_regex_highlighting = false`.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match) or args.match
    if not vim.treesitter.language.add(lang) then
      return
    end
    if pcall(vim.treesitter.start, args.buf, lang) and not builtin_indent[lang] then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
EOF
