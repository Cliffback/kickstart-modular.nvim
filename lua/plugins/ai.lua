-- [[ AI ]]

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
    keys = {
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
        '<leader>ot',
        function()
          require('opencode').toggle()
        end,
        mode = { 'n', 't' },
        desc = 'Toggle opencode',
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
      {
        '<leader>ou',
        function()
          require('opencode').command 'session.half.page.up'
        end,
        desc = 'Scroll opencode up',
      },
      {
        '<leader>od',
        function()
          require('opencode').command 'session.half.page.down'
        end,
        desc = 'Scroll opencode down',
      },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {}
      vim.o.autoread = true
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
