-- this runs when the plugin in required
-- this will only run once as the module will be cached
-- clear the cache with the following command
-- `:lua package.loaded['plugin-template'] = nil`

local enabled = false

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
    hidden_buffer_types = { 'terminal', 'nofile' },
    gitsigns = {
      enabled = true,
    }
  }
}

local should_hide_numbers = function(filetype, buftype)
  return vim.tbl_contains(M.config.hidden_file_types, filetype) or
      vim.tbl_contains(M.config.hidden_buffer_types, buftype)
end

-- Check if a line is in a staged hunk using gitsigns' cache
_G.is_line_staged = function(lnum, bufnr)
  if not package.loaded.gitsigns then
    return false
  end
  
  local ok, result = pcall(function()
    local cache = require('gitsigns.cache').cache
    
    if not cache[bufnr] then
      return false
    end
    
    local hunks_staged = cache[bufnr].hunks_staged
    if not hunks_staged then
      return false
    end
    
    for _, hunk in ipairs(hunks_staged) do
      local min_lnum = hunk.added.start
      local max_lnum = hunk.added.start + math.max(0, hunk.added.count - 1)
      if lnum >= min_lnum and lnum <= max_lnum then
        return true
      end
    end
    
    return false
  end)
  
  if ok then
    return result
  end
  
  return false
end

-- Get the gitsign symbol for a line with proper coloring (for statuscolumn display)
_G.get_gitsign_sign = function(lnum)
  if not M.config.gitsigns.enabled or not package.loaded.gitsigns then
    return " "
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local config = require('gitsigns.config').config
  
  -- Check staged hunks first
  local is_staged = _G.is_line_staged(lnum, bufnr)
  if is_staged then
    local cache = require('gitsigns.cache').cache
    if cache[bufnr] then
      local hunks_staged = cache[bufnr].hunks_staged
      if hunks_staged then
        for _, hunk in ipairs(hunks_staged) do
          local min_lnum = hunk.added.start
          local max_lnum = hunk.added.start + math.max(0, hunk.added.count - 1)
          if lnum >= min_lnum and lnum <= max_lnum then
            local signs_config = config.signs_staged
            local symbol = signs_config[hunk.type] and signs_config[hunk.type].text or '│'
            local hl_name = hunk.type:sub(1, 1):upper() .. hunk.type:sub(2)
            local hl_group = 'GitSignsStaged' .. hl_name
            return '%#' .. hl_group .. '#' .. symbol .. '%*'
          end
        end
      end
    end
  end
  
  -- Check unstaged hunks
  local gitsigns = require('gitsigns')
  local hunks = gitsigns.get_hunks(bufnr)
  if not hunks then
    return " "
  end

  for _, hunk in ipairs(hunks) do
    local min_lnum = hunk.added.start
    local max_lnum = hunk.added.start + math.max(0, hunk.added.count - 1)

    if lnum >= min_lnum and lnum <= max_lnum then
      local signs_config = config.signs
      local symbol = signs_config[hunk.type] and signs_config[hunk.type].text or '│'
      local hl_name = hunk.type:sub(1, 1):upper() .. hunk.type:sub(2)
      local hl_group = 'GitSigns' .. hl_name
      return '%#' .. hl_group .. '#' .. symbol .. '%*'
    end
  end

  return " "
end

-- StatusColumn function that builds the entire column with colors
_G.StatusColumn = function()
  if vim.v.virtnum > 0 then
    return ""
  end
  
  -- Get diagnostic signs
  local diag = "%s"
  
  -- Get line number
  local num = _G.get_label(vim.v.lnum, vim.v.relnum)
  
  -- Get gitsign with color
  local git = _G.get_gitsign_sign(vim.v.lnum)
  
  -- Format: Diag | Number | GitSign
  return diag .. "%=" .. num .. " " .. git
end

-- Defined on the global namespace to be used in Vimscript below.
_G.get_label = function(absnum, relnum)
  if not enabled then
    return absnum
  end

  -- Use numberwidth for consistent padding (set in update_status_column)
  local width = vim.wo.numberwidth

  -- Check if line numbers are disabled on the buffer nvim
  if not vim.wo.number then
    return ""
  end

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
         -- vim.opt.statuscolumn = ''
       end)
     else
        vim.api.nvim_win_call(win, function()
          -- Calculate and set consistent width based on total lines
          -- Minimum 4 to fit longest custom labels (e.g., "1444")
          local total_lines = vim.api.nvim_buf_line_count(buf)
          local width = math.max(4, #tostring(total_lines))
          vim.wo[win].numberwidth = width

              -- Format: Diag | Number(pad) | GitSign
              -- %s = diagnostic signs only
              -- %=%{...} = custom line number with right alignment and padding
               -- Use StatusColumn() function for proper coloring
                vim.opt.statuscolumn = "%!v:lua.StatusColumn()"
            end)
         end
    end
end

function M.enable_line_numbers()
  if enabled then
    return
  end

  for index, label in ipairs(M.config.labels) do
    if label ~= "" then
      vim.keymap.set({ 'n', 'v', 'o' }, label .. M.config.up_key, index .. 'k', { noremap = true })
      vim.keymap.set({ 'n', 'v', 'o' }, label .. M.config.down_key, index .. 'j', { noremap = true })
    end
  end

  enabled = true
  update_status_column()
end

function M.disable_line_numbers()
   if not enabled then
     return
   end

   for index, label in ipairs(M.config.labels) do
     if label ~= "" then
       vim.keymap.del({ 'n', 'v', 'o' }, label .. M.config.up_key)
       vim.keymap.del({ 'n', 'v', 'o' }, label .. M.config.down_key)
     end
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

    if M.config.gitsigns.enabled then
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "GitSignsUpdate",
        callback = function()
          vim.cmd.redraw({ bang = true })
        end
      })
    end
end

-- Disable gitsigns native sign column to avoid duplicates in statuscolumn
local function disable_gitsigns_signcolumn()
  if package.loaded.gitsigns then
    require('gitsigns').toggle_signs(false)
  end
end

function M.setup(config)
   M.config = vim.tbl_deep_extend("force", M.config, config or {})
   
   -- Disable gitsigns sign column when using statuscolumn display
   if M.config.gitsigns.enabled then
     vim.schedule(disable_gitsigns_signcolumn)
   end

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

   vim.api.nvim_create_user_command(
     'ComfyDebug',
     function()
       local bufnr = vim.api.nvim_get_current_buf()
       
       if not package.loaded.gitsigns then
         vim.notify("Gitsigns not loaded", vim.log.levels.WARN)
         return
       end
       
       local cache = require('gitsigns.cache').cache
       local hunks = require('gitsigns').get_hunks(bufnr)
       local hunks_staged = cache[bufnr] and cache[bufnr].hunks_staged or {}
       
       vim.notify("Hunks (unstaged): " .. #(hunks or {}), vim.log.levels.INFO)
       vim.notify("Hunks (staged): " .. #hunks_staged, vim.log.levels.INFO)
     end,
     { nargs = 0 }
   )

  vim.opt.relativenumber = true
  create_auto_commands()
  M.enable_line_numbers()
end

return M
