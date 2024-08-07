# LLM nvim plugin

Plugin for [Neovim](https://neovim.io/) that allows interacting with LLMs. Based on (Yacine's similar plugin)[https://github.com/yacineMTB/dingllm.nvim/tree/masters]

# Usage

```
{
  "shanetwinterhalter/llms.nvim",
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
  local system_prompt = 'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
  local helpful_prompt = 'You are a helpful assistant. What I have sent are my notes so far. You are very curt , yet helpful'
  local llm = require("llms")

  local function openai_help()
    llm.invoke_llm_and_stream_into_editor({
      url = 'https://api.openai.com/v1/chat/completions',
      model = 'gpt-4o',
      api_key_name = 'OPENAI_API_KEY',
      system_prompt = helpful_prompt,
      replace = false
    })
  end

  local function openai_replace()
    llm.invoke_llm_and_stream_into_editor({
      url = 'https://api.openai.com/v1/chat/completions',
      model = 'gpt-4o',
      api_key_name = 'OPENAI_API_KEY',
      system_prompt = system_prompt,
      replace = true
    })
  end

  vim.keymap.set({ 'n', 'v' }, '<leader>K', openai_help, { desc = 'llms openai help' })
  vim.keymap.set({ 'n', 'v' }, '<leader>k', openai_replace, { desc = 'llms openai code' })
  end,
}
```
