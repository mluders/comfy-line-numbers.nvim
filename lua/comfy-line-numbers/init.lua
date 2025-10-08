-- this runs when the plugin in required
-- this will only run once as the module will be cached
-- clear the cache with the following command
-- `:lua package.loaded['plugin-template'] = nil`

local enabled = false

-- start: default value is 1, must be a number, in [0,8]
-- end_: default value is 3, must be a number, in [2,9]
-- depth: default value is 3, must be a number, in [1,9]
function gen_labels(start, end_, depth)
  local start_num = type(start) == "number" and start or 1
  local end_num = type(end_) == "number" and end_ or 3
  local max_depth = type(depth) == "number" and depth or 3

  if start_num < 0 then
    error "Error: start number must >= 0"
  end
  if end_num < start_num then
    error "Error: end number must < start number"
  end
  if max_depth < 1 or max_depth > 9 then
    error "Error: depth must >= 1 and <= 9"
  end

  local labels = {}
  local digits = {}

  -- gen basic number set
  for i = start_num, end_num do
    table.insert(digits, tostring(i))
  end

  local function build(current, length)
    if length == 0 then
      table.insert(labels, current)
      return
    end
    for _, d in ipairs(digits) do
      build(current .. d, length - 1)
    end
  end

  for len = 1, max_depth do
    build("", len)
  end

  return labels
end

local DEFAULT_LABELS = gen_labels(1, 5, 3)

local M = {
  config = {
    labels = DEFAULT_LABELS,
    up_key = "k",
    down_key = "j",
    hidden_file_types = { "undotree" },
    hidden_buffer_types = { "terminal", "nofile" },
  },
}

local should_hide_numbers = function(filetype, buftype)
  return vim.tbl_contains(M.config.hidden_file_types, filetype)
    or vim.tbl_contains(M.config.hidden_buffer_types, buftype)
end

-- Defined on the global namespace to be used in Vimscript below.
_G.get_label = function(absnum, relnum)
  if not enabled then
    return absnum
  end

  if relnum == 0 then
    -- Pad current line number to match width
    return string.format("%-2d", vim.fn.line ".")
  elseif relnum > 0 and relnum <= #M.config.labels then
    -- Pad label to consistent width
    return string.format("%-2s", M.config.labels[relnum])
  else
    -- Pad absolute number to consistent width
    return string.format("%-2d", absnum)
  end
end

function update_status_column()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype

    if should_hide_numbers(filetype, buftype) then
      vim.api.nvim_win_call(win, function()
        vim.opt.statuscolumn = ""
      end)
    else
      vim.api.nvim_win_call(win, function()
        vim.opt.statuscolumn = "%=%s%=%{v:lua.get_label(v:lnum, v:relnum)} "
      end)
    end
  end
end

function M.enable_line_numbers()
  if enabled then
    return
  end

  for index, label in ipairs(M.config.labels) do
    vim.keymap.set({ "n", "v", "o" }, label .. M.config.up_key, index .. "k", { noremap = true })
    vim.keymap.set({ "n", "v", "o" }, label .. M.config.down_key, index .. "j", { noremap = true })
  end

  enabled = true
  update_status_column()
end

function M.disable_line_numbers()
  if not enabled then
    return
  end

  for index, label in ipairs(M.config.labels) do
    vim.keymap.del({ "n", "v", "o" }, label .. M.config.up_key)
    vim.keymap.del({ "n", "v", "o" }, label .. M.config.down_key)
  end

  enabled = false
  update_status_column()
end

function create_auto_commands()
  local group = vim.api.nvim_create_augroup("ComfyLineNumbers", { clear = true })

  vim.api.nvim_create_autocmd({ "WinNew", "BufWinEnter", "BufEnter", "TermOpen" }, {
    group = group,
    pattern = "*",
    callback = update_status_column,
  })
end

function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  vim.api.nvim_create_user_command("ComfyLineNumbers", function(args)
    if args.args == "enable" then
      M.enable_line_numbers()
    elseif args.args == "disable" then
      M.disable_line_numbers()
    elseif args.args == "toggle" then
      if enabled then
        M.disable_line_numbers()
      else
        M.enable_line_numbers()
      end
    else
      print "Invalid argument."
    end
  end, { nargs = 1 })

  vim.opt.relativenumber = true
  create_auto_commands()
  M.enable_line_numbers()
end

return M
