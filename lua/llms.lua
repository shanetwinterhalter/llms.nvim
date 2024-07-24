local M = {}
local Job = require 'plenary.job'
local active_job = nil

local function get_api_key(name)
  return os.getenv(name)
end

local function write_string_at_cursor(str)
  vim.api.nvim_put(vim.split(str, '\n'), 'c', true, true)
end

function make_curl_args(opts)
  local url = opts.url
  local api_key = get_api_key(opts.api_key_name)
  local data = {
    messages = { 
      { role = 'system', content = opts.system_prompt }, 
      { role = 'user', content = opts.prompt } 
    },
    model = opts.model,
    temperature = 0.7,
    stream = true,
  }
  local args = { '-N', '-X', 'POST', '-H', 'Content-Type: application/json', '-d', vim.json.encode(data), '-H', 'Authorization: Bearer ' .. api_key, url}

  return args
end

function handle_data(data, event)
  write_string_at_cursor(data)
end

function M.invoke_llm_and_stream_into_editor(opts)
  local args = make_curl_args(opts)
  local curr_event_state = nil

  local function parse_and_call(line)
    local event = line:match '^event: (.+)$'
    if event then
      curr_event_state = event
      return
    end
    local data_match = line:match '^data: (.+)$'
    if data_match then
      handle_data(data_match, curr_event_state)
    end
  end

  if active_job then
    active_job:shutdown()
    active_job = nil
  end

  active_job = Job:new {
    command = 'curl',
    args = args,
    on_stdout = function(_, out)
      parse_and_call(out)
    end,
    on_stderr = function(_, _) end,
    on_exit = function()
      active_job = nil
    end,
  }

  active_job:start()
  
  -- Allow cancelling the job
  -- vim.api.nvim_create_autocmd('

  return active_job
end

return M
