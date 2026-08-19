-- [[ Completion ]]
--
-- blink.cmp replaces nvim-cmp, cmp-nvim-lsp, cmp-path and cmp_luasnip.
--
-- The win is latency: blink's fuzzy matcher is Rust (SIMD) where nvim-cmp's is
-- Lua, and this config drives ts_ls over a pnpm monorepo where completion
-- responses routinely run to thousands of items. nvim-cmp is not abandoned,
-- just slow-moving; the reason to switch is speed and one plugin instead of
-- four.
--
-- version = '1.*' pulls a prebuilt binary from the GitHub release, which
-- matters because there is no cargo on this machine.

return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    -- NOTE: also a dependency of nvim-lspconfig, because config/lsp.lua needs
    -- get_lsp_capabilities() at server-setup time. blink does not register
    -- capabilities itself, so in practice it loads with lspconfig on
    -- BufReadPre rather than waiting for InsertEnter.
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        dependencies = { 'rafamadriz/friendly-snippets' },
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = { preset = 'luasnip' },

      keymap = {
        preset = 'none',
        -- Kept identical to the previous nvim-cmp bindings, including the
        -- unusual <S-Tab> = accept.
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<S-Tab>'] = { 'accept', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
      },

      appearance = { nerd_font_variant = 'mono' },

      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        -- Matches the old completeopt = 'menu,menuone,noinsert'.
        list = { selection = { preselect = true, auto_insert = false } },
        -- <Tab> belongs to copilot.lua; don't let blink draw ghost text too.
        ghost_text = { enabled = false },
      },

      sources = {
        -- `buffer` is deliberately absent: the previous nvim-cmp config used
        -- only nvim_lsp, luasnip and path, and buffer-word noise was not wanted.
        default = { 'lsp', 'path', 'snippets' },
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },

      -- Neovim's own cmdline completion is fine and this avoids blink taking
      -- over `:` and `/`.
      cmdline = { enabled = false },
    },
    opts_extend = { 'sources.default' },
  },
}

-- vim: ts=2 sts=2 sw=2 et
