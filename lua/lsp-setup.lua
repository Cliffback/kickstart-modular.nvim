-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local keymaps = require('keymaps')

local on_attach_keymaps = function(_, bufnr)
  keymaps.set_lsp_keymaps(_, bufnr)

  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
end

-- document existing key chains
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
  { "<leader>", group = "VISUAL <leader>" },
  { "<leader>h", group = "Git [H]unk" },
}, { mode = "v" })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.

local util = require("lspconfig.util")

local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  bashls = {},
  cmake = {},
  omnisharp = {},
  dockerls = {},
  docker_compose_language_service = {},
  eslint = {},
  gradle_ls = {},
  html = {},
  kotlin_language_server = {},
  marksman = {},
  pylsp = {},
  shopify_theme_ls = {},
  sqlls = {},
  ts_ls = {
  --   -- root_dir = util.root_pattern("package.json", ".git", "tsconfig.base.json")
  },
  tailwindcss = {},
  yamlls = {

    yaml = {
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = require('schemastore').yaml.schemas {
        -- select subset from the JSON schema catalog
        --select = {
        --  'kustomization.yaml',
        --  'bitbucket-pipelisnes'
        --},

        -- additional schemas (not in the catalog)
        --extra = {
        --  url = 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json',
        --  name = 'Argo CD Application',
        --  fileMatch = 'argocd-application.yaml'
        --}
      },
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
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

local handlers = {
  omnisharp = {
    ["textDocument/definition"] = require('omnisharp_extended').handler,
  }
}

local on_attach = {
  default = on_attach_keymaps,
  ts_ls = function(client, bufnr)
    if client.name == "ts_ls" then
      -- Disable ts_ls formatting to use manual eslint on save
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
    on_attach_keymaps(client, bufnr)
  end
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach[server_name] or on_attach.default,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
      handlers = handlers[server_name]
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
