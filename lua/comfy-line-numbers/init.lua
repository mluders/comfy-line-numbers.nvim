-- this runs when the plugin in required
-- this will only run once as the module will be cached
-- clear the cache with the following command
-- `:lua package.loaded['plugin-template'] = nil`

local enabled = false

-- Calculate total number of combinations for given base and max_digits
-- Formula: base^1 + base^2 + ... + base^max_digits = (base^(max_digits+1) - base) / (base - 1)
local function calculate_combinations(base, max_digits)
  local total = 0
  for i = 1, max_digits do
    total = total + math.pow(base, i)
  end
  return total
end

-- Generate labels based on the base (3-9) and max_digits
-- For example, base=5, max_digits=3 generates all combinations using digits {1,2,3,4,5}:
-- 1, 2, 3, 4, 5, 11, 12, ..., 555
local function generate_labels(base, max_digits)
  if base < 3 or base > 9 then
    error("base must be between 3 and 9")
  end

  local total_combinations = calculate_combinations(base, max_digits)
  if total_combinations < 100 then
    error(string.format(
      "Configuration yields only %d combinations (minimum 100 required). " ..
      "Please increase base (currently %d) or max_digits (currently %d) or both.",
      total_combinations, base, max_digits
    ))
  end

  local labels = {}

  -- Generate combinations for each digit length
  for digit_count = 1, max_digits do
    local function generate_recursive(current, remaining_digits)
      if remaining_digits == 0 then
        table.insert(labels, current)
        return
      end

      for digit = 1, base do
        generate_recursive(current .. tostring(digit), remaining_digits - 1)
      end
    end

    generate_recursive("", digit_count)
  end

  return labels
end

local DEFAULT_LABELS = {
  "1",
  "2",
  "3",
  "4",
  "5",
  "11",
  "12",
  "13",
  "14",
  "15",
  "21",
  "22",
  "23",
  "24",
  "25",
  "31",
  "32",
  "33",
  "34",
  "35",
  "41",
  "42",
  "43",
  "44",
  "45",
  "51",
  "52",
  "53",
  "54",
  "55",
  "111",
  "112",
  "113",
  "114",
  "115",
  "121",
  "122",
  "123",
  "124",
  "125",
  "131",
  "132",
  "133",
  "134",
  "135",
  "141",
  "142",
  "143",
  "144",
  "145",
  "151",
  "152",
  "153",
  "154",
  "155",
  "211",
  "212",
  "213",
  "214",
  "215",
  "221",
  "222",
  "223",
  "224",
  "225",
  "231",
  "232",
  "233",
  "234",
  "235",
  "241",
  "242",
  "243",
  "244",
  "245",
  "251",
  "252",
  "253",
  "254",
  "255",
}

local M = {
  config = {
    labels = DEFAULT_LABELS,
    up_key = 'k',
    down_key = 'j',
    hidden_file_types = { 'undotree' },
    hidden_buffer_types = { 'terminal', 'nofile' }
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

  -- Use numberwidth for consistent padding (set in update_status_column)
  local width = vim.wo.numberwidth

  -- Check if relativenumber is enabled (respects nvim-numbertoggle)
  if not vim.wo.relativenumber then
    return string.format("%" .. width .. "d", absnum)
  end

  if relnum == 0 then
    -- Pad current line number to match width
    return string.format("%" .. width .. "d", vim.fn.line ".")
  elseif relnum > 0 and relnum <= #M.config.labels then
    -- Pad label to consistent width
    return string.format("%" .. width .. "s", M.config.labels[relnum])
  else
    -- Pad absolute number to consistent width
    return string.format("%" .. width .. "d", absnum)
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
      end)
    else
      vim.api.nvim_win_call(win, function()
        -- Calculate and set consistent width based on total lines
        -- Minimum 4 to fit longest custom labels (e.g., "1444")
        local total_lines = vim.api.nvim_buf_line_count(buf)
        local width = math.max(4, #tostring(total_lines))
        vim.wo[win].numberwidth = width

        vim.opt.statuscolumn = '%=%s%=%{v:virtnum > 0 ? "" : v:lua.get_label(v:lnum, v:relnum)} '
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

  vim.api.nvim_create_autocmd({ "WinNew", "BufWinEnter", "BufEnter", "TermOpen", "InsertEnter", "InsertLeave" }, {
    group = group,
    pattern = "*",
    callback = update_status_column
  })
end

function M.setup(config)
  config = config or {}

  -- If labels is NOT explicitly provided, generate them from base and max_digits
  if not config.labels then
    local base = config.base or 5  -- default base = 5
    local max_digits = config.max_digits or 10  -- default max_digits = 10

    if base < 3 or base > 9 then
      error("base must be between 3 and 9")
    end

    config.labels = generate_labels(base, max_digits)
  end
  -- If labels IS provided, use it directly (ignore base and max_digits)

  M.config = vim.tbl_deep_extend("force", M.config, config)

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
