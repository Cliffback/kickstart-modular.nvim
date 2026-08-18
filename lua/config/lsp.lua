-- [[ LSP configuration ]]

local keymaps = require 'config.keymaps'
local detect = require 'utils.detect-os'

-- Buffer-local LSP keymaps.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    keymaps.set_lsp_keymaps(nil, ev.buf)
  end,
})

-- Server configurations.
-- Keys are server names, values are the `settings` table for that server.
local servers = {
  bashls = {},
  biome = {},
  cmake = {},
  dockerls = {},
  docker_compose_language_service = {},
  eslint = {},
  oxlint = {},
  html = {},
  marksman = {},
  shopify_theme_ls = {},
  sqlls = {},
  ts_ls = {},
  tailwindcss = {},
  yamlls = {
    yaml = {
      schemaStore = { enable = false, url = '' },
      schemas = require('schemastore').yaml.schemas {},
      format = { enable = true, singleQuote = false, bracketSpacing = true },
      validate = true,
      completion = true,
    },
  },
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

if not detect.IS_WSL then
  servers.omnisharp = {}
  servers.gradle_ls = {}
  servers.kotlin_language_server = {}
  servers.pylsp = {}
end

-- Mason. `automatic_enable = false` is important: mason-lspconfig v2 otherwise
-- calls vim.lsp.enable() on *every installed* server, which silently defeated
-- the IS_WSL exclusions above.
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = false,
}

-- Non-LSP tooling that mason-lspconfig will not install for us.
require('mason-tool-installer').setup {
  ensure_installed = {
    'stylua', -- .stylua.toml exists in this repo but nothing was running it
    'prettierd',
    'shfmt',
    'ruff',
  },
  run_on_start = true,
  auto_update = false,
}

-- Completion capabilities, applied to every server at once.
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Server-specific overrides layered on top of the settings table.
local overrides = {
  omnisharp = {
    handlers = {
      ['textDocument/definition'] = require('omnisharp_extended').handler,
    },
  },
  -- Widened so these servers still attach when Neovim reclassifies an .html
  -- file as `htmldjango` (see config/autocmds.lua).
  html = {
    filetypes = { 'html', 'templ', 'htmldjango', 'liquid' },
  },
  shopify_theme_ls = {
    filetypes = { 'liquid', 'htmldjango' },
  },
  tailwindcss = {
    filetypes = {
      'html',
      'htmldjango',
      'liquid',
      'css',
      'scss',
      'sass',
      'less',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'vue',
      'svelte',
      'astro',
    },
  },
}

for server_name, settings in pairs(servers) do
  vim.lsp.config(server_name, vim.tbl_deep_extend('force', { settings = settings }, overrides[server_name] or {}))
end

vim.lsp.enable(vim.tbl_keys(servers))

-- sourcekit is macOS-only. The old config hardcoded an /Applications/Xcode.app
-- path and enabled it unconditionally, so on Linux/WSL it spawn-failed.
if detect.IS_MAC then
  local sourcekit = vim.trim(vim.fn.system 'xcrun --find sourcekit-lsp')
  if vim.v.shell_error == 0 and sourcekit ~= '' then
    vim.lsp.config('sourcekit', { cmd = { sourcekit } })
    vim.lsp.enable 'sourcekit'
  end
end

-- On-save `source.fixAll.*` code actions (oxlint / eslint / biome).
require('config.lsp-fixall').setup()

-- vim: ts=2 sts=2 sw=2 et
