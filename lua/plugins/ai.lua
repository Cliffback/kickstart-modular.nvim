-- [[ AI ]]

-- opencode.nvim is a bridge, not a UI: it connects to a running `opencode`
-- server and drives its TUI. It deliberately owns no window, which is why it
-- exposes no `toggle()` - the TUI lives in whatever terminal you put it in.
--
-- So we put it in a toggleterm float and toggle *that*. opencode.nvim finds it
-- by scanning for `opencode` processes and matching their cwd against Neovim's,
-- so this instance is discovered automatically.
local opencode_term
local function get_opencode_term()
  if not opencode_term then
    opencode_term = require('toggleterm.terminal').Terminal:new {
      cmd = 'opencode --port',
      direction = 'float',
      hidden = true,
      close_on_exit = false,
      float_opts = { border = 'curved' },
    }
  end
  return opencode_term
end

return {
  -- NOTE: github/copilot.vim was removed. It ran alongside copilot.lua, giving
  -- two ghost-text providers, and claimed <Tab> in insert mode.
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cmd = 'Copilot',
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        max_width = 80,
        keymap = {
          -- <Tab> is safe here: copilot.lua registers this buffer-locally with
          -- passthrough, so it only accepts while a suggestion is visible and
          -- otherwise falls back to whatever <Tab> was already bound to. Same
          -- behaviour copilot.vim's copilot#Accept() had.
          accept = '<Tab>',
          accept_word = '<M-Right>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<M-h>',
        },
      },
      panel = { enabled = false },
    },
  },

  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      'zbirenbaum/copilot.lua',
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    cmd = {
      'CopilotChat',
      'CopilotChatOpen',
      'CopilotChatClose',
      'CopilotChatToggle',
      'CopilotChatStop',
      'CopilotChatReset',
      'CopilotChatSave',
      'CopilotChatLoad',
      'CopilotChatPrompts',
      'CopilotChatModels',
      'CopilotChatDocs',
      'CopilotChatExplain',
      'CopilotChatFix',
    },
    keys = {
      {
        '<leader>cci',
        function()
          vim.ui.input({ prompt = 'CopilotChat: ' }, function(input)
            if input and input ~= '' then
              vim.cmd('CopilotChat ' .. input)
            end
          end)
        end,
        desc = 'Open chat window with input',
      },
      { '<leader>cco', '<cmd>CopilotChatOpen<CR>', desc = 'Open chat window' },
      { '<leader>ccc', '<cmd>CopilotChatClose<CR>', desc = 'Close chat window' },
      { '<leader>cct', '<cmd>CopilotChatToggle<CR>', desc = 'Toggle chat window' },
      { '<leader>ccx', '<cmd>CopilotChatStop<CR>', desc = 'Stop current copilot output' },
      { '<leader>ccr', '<cmd>CopilotChatReset<CR>', desc = 'Reset chat window' },
      {
        '<leader>ccs',
        function()
          vim.ui.input({ prompt = 'Save chat as: ' }, function(name)
            if name and name ~= '' then
              vim.cmd('CopilotChatSave ' .. name)
            end
          end)
        end,
        desc = 'Save chat history to file',
      },
      {
        '<leader>ccl',
        function()
          vim.ui.input({ prompt = 'Load chat: ' }, function(name)
            if name and name ~= '' then
              vim.cmd('CopilotChatLoad ' .. name)
            end
          end)
        end,
        desc = 'Load chat history from file',
      },
      -- NOTE: <leader>cch/<leader>ccp used to call CopilotChat.actions via
      -- CopilotChat.integrations.telescope, and <leader>ccd called
      -- :CopilotChatDebugInfo. All three were removed upstream, so those
      -- mappings had been silently broken.
      { '<leader>ccp', '<cmd>CopilotChatPrompts<CR>', desc = 'Show [P]rompt actions' },
      { '<leader>ccm', '<cmd>CopilotChatModels<CR>', desc = 'Select [M]odel' },
      { '<leader>ccd', '<cmd>CopilotChatDocs<CR>', mode = { 'n', 'x' }, desc = 'Add [D]ocumentation for selection' },
      { '<leader>cce', '<cmd>CopilotChatExplain<CR>', mode = { 'n', 'x' }, desc = '[E]xplain selection' },
      { '<leader>ccf', '<cmd>CopilotChatFix<CR>', mode = { 'n', 'x' }, desc = '[F]ix selection' },
    },
    opts = {
      model = 'claude-opus-4.5',
      window = {
        layout = 'float',
        relative = 'editor',
        width = 0.5,
        height = 0.5,
      },
      mappings = {
        complete = { insert = '' },
      },
    },
  },

  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    dependencies = { 'akinsho/toggleterm.nvim' },
    keys = {
      {
        '<leader>ot',
        function()
          get_opencode_term():toggle()
        end,
        mode = { 'n', 't' },
        desc = 'Toggle opencode',
      },
      {
        '<leader>oa',
        function()
          require('opencode').ask('@this: ', { submit = true })
        end,
        mode = { 'n', 'x' },
        desc = 'Ask opencode',
      },
      {
        '<leader>ox',
        function()
          require('opencode').select()
        end,
        mode = { 'n', 'x' },
        desc = 'Execute opencode action',
      },
      {
        '<leader>oo',
        function()
          return require('opencode').operator '@this '
        end,
        mode = { 'n', 'x' },
        expr = true,
        desc = 'Add range to opencode',
      },
      {
        '<leader>ool',
        function()
          return require('opencode').operator '@this ' .. '_'
        end,
        expr = true,
        desc = 'Add line to opencode',
      },
      -- Contexts other than @this had no bindings at all.
      {
        '<leader>od',
        function()
          require('opencode').ask 'Explain @diagnostics: '
        end,
        desc = 'Ask opencode about @[d]iagnostics',
      },
      {
        '<leader>ob',
        function()
          require('opencode').ask '@buffers: '
        end,
        desc = 'Ask opencode about @[b]uffers',
      },
      {
        '<leader>oq',
        function()
          require('opencode').ask '@quickfix: '
        end,
        desc = 'Ask opencode about @[q]uickfix',
      },
      -- Scrolling the TUI from Neovim. Moved off <leader>ou/<leader>od to the
      -- keys upstream recommends, freeing <leader>od for @diagnostics.
      {
        '<C-S-u>',
        function()
          require('opencode').command 'session.half.page.up'
        end,
        desc = 'Scroll opencode up',
      },
      {
        '<C-S-d>',
        function()
          require('opencode').command 'session.half.page.down'
        end,
        desc = 'Scroll opencode down',
      },
    },
    init = function()
      -- Set before the plugin loads: opencode.config resolves vim.g at require
      -- time. Start the server in our toggleterm float rather than the default
      -- raw `vsplit term://opencode --port`.
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function()
            get_opencode_term():open()
          end,
        },
      }
      vim.o.autoread = true
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
