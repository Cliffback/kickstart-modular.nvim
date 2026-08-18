-- [[ Treesitter ]]
--
-- NOTE: this is still the `master` branch, which upstream has frozen and
-- declared supported only up to Nvim 0.11. On 0.12 its custom query directives
-- crash on `<script type="...">` in HTML, because Neovim removed the `all`
-- compatibility option from add_predicate/add_directive. Migrating to the
-- `main` branch is Phase 3.

return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'c_sharp',
        'cmake',
        'cpp',
        'css',
        'csv',
        'go',
        'html',
        'http',
        'javascript',
        'json',
        'kotlin',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'python',
        'rust',
        'sql',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
      },
      auto_install = false,
      sync_install = false,
      ignore_install = {},
      modules = {},
      highlight = { enable = true },
      indent = { enable = true },
      -- NOTE: incremental_selection is intentionally left off. Neovim 0.12
      -- ships this natively in visual mode as `an` / `in` / `]n` / `[n`, which
      -- also takes a count and falls back to LSP selection ranges.
      -- See `:h treesitter-incremental-selection`.
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
        swap = {
          enable = true,
          swap_next = { ['<leader>a'] = '@parameter.inner' },
          swap_previous = { ['<leader>A'] = '@parameter.inner' },
        },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
