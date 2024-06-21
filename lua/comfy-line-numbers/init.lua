-- this runs when the plugin in required
-- this will only run once as the module will be cached
-- clear the cache with the following command
-- `:lua package.loaded['plugin-template'] = nil`

local labels = {
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
    labels = labels,
    up_key = 'k',
    down_key ='j',
    current_line_label = '=>'
  }
}

local function define_signs()
  for i=1,99,1 do
    vim.cmd([[sign define comfy-]] .. i .. [[ text=]] .. i .. [[ texthl=LineNr]])
  end

  vim.cmd([[sign define comfy-current-line text=]] .. M.config.current_line_label .. [[ texthl=CursorLineNr]])
end

local function place_signs()
  local current_file = vim.fn.expand('%')
  if current_file == nil or current_file == '' then return end

  vim.cmd([[sign unplace * group=comfy]])

  local current_line = vim.fn.line('.')
  local current_id = 1

  for i=1,#M.config.labels,1 do
    label = M.config.labels[i]

    if current_line - i > 0 then
      vim.cmd([[sign place ]] .. current_id .. [[ line=]] .. current_line - i .. [[ name=comfy-]] .. label .. [[ group=comfy file=]] .. current_file)
      current_id = current_id + 1
    end

    vim.cmd([[sign place ]] .. current_id .. [[ line=]] .. current_line + i .. [[ name=comfy-]] .. label .. [[ group=comfy file=]] .. current_file)
    current_id = current_id + 1
  end

  vim.cmd([[sign place ]] .. current_id .. [[ line=]] .. current_line .. [[ name=comfy-current-line group=comfy file=]] .. current_file)
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorMoved', 'CursorMovedI' }, {
  group = vim.api.nvim_create_augroup("comfy-signs", {}),
  pattern = { '*' },
  callback = function()
    place_signs()
  end
})

function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  define_signs()

  for index, label in ipairs(M.config.labels) do
    vim.keymap.set({ 'n', 'v', 'o', 's' }, label .. M.config.up_key, index .. 'k', { noremap = true })
    vim.keymap.set({ 'n', 'v', 'o', 's' }, label .. M.config.down_key, index .. 'j', { noremap = true })
  end
end

return M
