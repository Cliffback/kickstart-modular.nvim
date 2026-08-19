-- [[ Debugging ]]
--
-- This whole stack used to load at startup and cost ~226 ms, over a third of
-- total startup time, almost all of it in
-- `mason-nvim-dap.mappings.configurations`. It is now behind the F-keys.
--
-- NOTE: `microsoft/vscode-js-debug` and `mxsdev/nvim-dap-vscode-js` were
-- removed. nvim-dap-vscode-js was last updated in October 2023, and the
-- vscode-js-debug build step (`npx gulp vsDebugServerBundle`, which pulls
-- Playwright/Chromium) failed on every `:Lazy sync`. That combination is why
-- JS debugging never worked reliably here.
--
-- To add JS/TS debugging later, the current approach is to install
-- `js-debug-adapter` via Mason (already present) and register it directly:
--
--   local dap = require('dap')
--   dap.adapters['pwa-node'] = {
--     type = 'server', host = 'localhost', port = '${port}',
--     executable = {
--       command = 'js-debug-adapter',
--       args = { '${port}' },
--     },
--   }
--   dap.configurations.typescript = { { type = 'pwa-node', request = 'launch',
--     name = 'Launch file', program = '${file}', cwd = '${workspaceFolder}' } }

local keys = {
  {
    '<F1>',
    function()
      require('dap').step_into()
    end,
    desc = 'Debug: Step Into',
  },
  {
    '<F2>',
    function()
      require('dap').step_over()
    end,
    desc = 'Debug: Step Over',
  },
  {
    '<F3>',
    function()
      require('dap').step_out()
    end,
    desc = 'Debug: Step Out',
  },
  {
    '<F4>',
    function()
      require('dap').continue()
    end,
    desc = 'Debug: Start/Continue',
  },
  {
    '<F9>',
    function()
      require('dap').toggle_breakpoint()
    end,
    desc = 'Debug: Toggle Breakpoint',
  },
  {
    '<F10>',
    function()
      require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end,
    desc = 'Debug: Set Conditional Breakpoint',
  },
  {
    '<F11>',
    function()
      require('dapui').toggle()
    end,
    desc = 'Debug: Toggle UI',
  },
}

return {
  {
    'mfussenegger/nvim-dap',
    keys = keys,
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      {
        'Cliffback/netcoredbg-macOS-arm64.nvim',
        cond = function()
          return require('utils.detect-os').IS_MAC
        end,
        dependencies = { 'ellisonleao/dotenv.nvim' },
      },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},
        ensure_installed = {},
      }

      dapui.setup()

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
