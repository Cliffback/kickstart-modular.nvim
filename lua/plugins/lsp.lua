-- [[ LSP ]]
--
-- The actual server configuration lives in lua/config/lsp.lua; this file only
-- declares the plugins.

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- NOTE: williamboman/* is archived; mason-org/* is the maintained home.
      { 'mason-org/mason.nvim', config = true },
      'mason-org/mason-lspconfig.nvim',
      -- Installs non-LSP tooling (stylua, prettierd, shfmt, ruff) that
      -- mason-lspconfig does not handle.
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
      'b0o/schemastore.nvim',
      'Hoffs/omnisharp-extended-lsp.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      require 'config.lsp'
    end,
  },

  -- TypeScript project-wide type checking
  {
    'dmmulroy/tsc.nvim',
    cmd = 'TSC',
    opts = {
      use_trouble_qflist = true,
      auto_close_qflist = true,
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
