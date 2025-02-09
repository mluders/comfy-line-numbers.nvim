-- this runs when the plugin in required
-- this will only run once as the module will be cached
-- clear the cache with the following command
-- `:lua package.loaded['plugin-template'] = nil`

local enabled = false

local DEFAULT_LABELS = {
  '1',
  '2',
  '3',
  '4',
  '5',
  '11',
  '12',
  '13',
  '14',
  '15',
  '21',
  '22',
  '23',
  '24',
  '25',
  '31',
  '32',
  '33',
  '34',
  '35',
  '41',
  '42',
  '43',
  '44',
  '45',
  '51',
  '52',
  '53',
  '54',
  '55',
}

local M = {
  config = {
    labels = DEFAULT_LABELS,
    up_key = 'k',
    down_key = 'j',
    hidden_file_types = { 'undotree' },
    hidden_buffer_types = { 'terminal' }
  }
}

local should_hide_numbers = function(filetype, buftype)
  return vim.tbl_contains(M.config.hidden_file_types, filetype) or
      vim.tbl_contains(M.config.hidden_buffer_types, buftype)
end

-- Defined on the global namespace to be used in Vimscript below.
_G.get_label = function(absnum, relnum)
  if not enabled then
    return absnum
  end

  if relnum == 0 then
    return vim.fn.line('.')
  elseif relnum > 0 and relnum <= #M.config.labels then
    return M.config.labels[relnum]
  else
    return absnum
  end
end

function update_status_column()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype

    if should_hide_numbers(filetype, buftype) then
      vim.api.nvim_win_call(win, function()
        vim.opt.statuscolumn = ''
        vim.cmd('mod') -- force redraw
      end)
    else
      vim.api.nvim_win_call(win, function()
        vim.opt.statuscolumn = '%=%s%=%{v:lua.get_label(v:lnum, v:relnum)} '
        vim.cmd('mod') -- force redraw
      end)
    end
  end
end

function M.enable_line_numbers()
  if enabled then
    return
  end

  for index, label in ipairs(M.config.labels) do
    vim.keymap.set({ 'n', 'v', 'o' }, label .. M.config.up_key, index .. 'k', { noremap = true })
    vim.keymap.set({ 'n', 'v', 'o' }, label .. M.config.down_key, index .. 'j', { noremap = true })
  end

  enabled = true
  update_status_column()
end

function M.disable_line_numbers()
  if not enabled then
    return
  end

  for index, label in ipairs(M.config.labels) do
    vim.keymap.del({ 'n', 'v', 'o' }, label .. M.config.up_key)
    vim.keymap.del({ 'n', 'v', 'o' }, label .. M.config.down_key)
  end


  enabled = false
  update_status_column()
end

function create_auto_commands()
  local group = vim.api.nvim_create_augroup("ComfyLineNumbers", { clear = true })

  vim.api.nvim_create_autocmd({ "WinNew", "BufWinEnter", "BufEnter", "TermOpen" }, {
    group = group,
    pattern = "*",
    callback = update_status_column
  })
end

function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  vim.api.nvim_create_user_command(
    'ComfyLineNumbers',
    function(args)
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
        print("Invalid argument.")
      end
    end,
    { nargs = 1 }
  )

  vim.opt.relativenumber = true
  create_auto_commands()
  M.enable_line_numbers()
end

return M
