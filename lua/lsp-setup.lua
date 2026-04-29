-- [[ Configure LSP ]]
local keymaps = require('keymaps')
local detect = require('utils.detect-os')

-- Set up LSP keymaps via LspAttach autocmd (replaces on_attach)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    keymaps.set_lsp_keymaps(nil, ev.buf)
  end,
})

-- Document existing key chains
local wk = require("which-key")

wk.add({
  { "<leader>c", group = "[C]ode" },
  { "<leader>d", group = "[D]ocument" },
  { "<leader>g", group = "[G]it" },
  { "<leader>h", group = "Git [H]unk" },
  { "<leader>r", group = "[R]ename" },
  { "<leader>s", group = "[S]earch" },
  { "<leader>t", group = "[T]oggle" },
  { "<leader>w", group = "[W]orkspace" },
})

-- Visual mode mappings
wk.add({
  { "<leader>",  group = "VISUAL <leader>" },
  { "<leader>h", group = "Git [H]unk" },
}, { mode = "v" })

-- Mason setup for installing LSP servers
require('mason').setup()
require('mason-lspconfig').setup {
  automatic_installation = true,
}

-- Server configurations
-- Keys are server names, values are settings tables passed to vim.lsp.config
local servers = {
  bashls = {},
  biome = {},
  cmake = {},
  dockerls = {},
  docker_compose_language_service = {},
  eslint = {},
  html = {},
  marksman = {},
  shopify_theme_ls = {},
  sqlls = {},
  ts_ls = {},
  tailwindcss = {},
  yamlls = {
    yaml = {
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = require('schemastore').yaml.schemas {},
      format = {
        enable = true,
        singleQuote = false,
        bracketSpacing = true
      },
      validate = true,
      completion = true
    }
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

-- Ensure the servers above are installed
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Configure each server using vim.lsp.config
for server_name, settings in pairs(servers) do
  local config = {
    capabilities = capabilities,
    settings = settings,
  }

  -- Server-specific overrides
  if server_name == 'omnisharp' then
    config.handlers = {
      ["textDocument/definition"] = require('omnisharp_extended').handler,
    }
  end

  vim.lsp.config(server_name, config)
end

-- Enable all configured servers
vim.lsp.enable(vim.tbl_keys(servers))
-- vim: ts=2 sts=2 sw=2 et
