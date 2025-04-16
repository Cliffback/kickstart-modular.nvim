-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    
    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   cmp.mapping.abort()
    --   if vim.fn["copilot#Visible"] then
    --     local copilot_keys = vim.fn["copilot#Accept"]()
    --     if copilot_keys ~= "" then
    --       vim.api.nvim_feedkeys(copilot_keys, "i", true)
    --     end
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
        -- ['<C-n>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_locally_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    -- ['<C-p>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.locally_jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    -- Use Copilot to complete the current word
    -- ["<Right>"] = cmp.mapping(function(fallback)
    --   cmp.mapping.abort()
    --   local copilot_keys = vim.fn["copilot#Accept"]()
    --   if copilot_keys ~= "" then
    --     vim.api.nvim_feedkeys(copilot_keys, "i", true)
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- vim: ts=2 sts=2 sw=2 et
