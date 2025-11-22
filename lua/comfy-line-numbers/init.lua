-- this runs when the plugin in required
-- this will only run once as the module will be cached
-- clear the cache with the following command
-- `:lua package.loaded['plugin-template'] = nil`

local enabled = false
local gitsigns_ns = vim.api.nvim_create_namespace('comfy_gitsigns')

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
      signs = {
        add = '┃',
        change = '┃',
        delete = '▁',
        topdelete = '▔',
        changedelete = '~',
        untracked = '┆',
      },
      signs_staged_enable = true,
      signs_staged = {
        add = '┃',
        change = '┃',
        delete = '▁',
        topdelete = '▔',
        changedelete = '~',
        untracked = '┆',
      }
    }
  }
}

local should_hide_numbers = function(filetype, buftype)
  return vim.tbl_contains(M.config.hidden_file_types, filetype) or
      vim.tbl_contains(M.config.hidden_buffer_types, buftype)
end





-- Check if a line is in a staged hunk using gitsigns internal cache
_G.is_line_staged = function(lnum, bufnr)
  -- Try to access gitsigns internal cache to get staged hunks
  local ok, result = pcall(function()
    -- Get the gitsigns manager to access internal cache
    local manager = require('gitsigns.manager')
    local cache = manager.cache
    
    if not cache or not cache[bufnr] then
      return false
    end
    
    local cache_entry = cache[bufnr]
    local hunks_staged = cache_entry.hunks_staged
    
    if not hunks_staged then
      return false
    end
    
    -- Check if line is in any staged hunk
    for _, hunk in ipairs(hunks_staged) do
      local min_lnum = math.max(1, hunk.added.start)
      local max_lnum = math.max(1, hunk.added.start + math.max(0, hunk.added.count - 1))
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
    return " "  -- Return padding space if gitsigns disabled
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local gitsigns = require('gitsigns')
  
  -- Get hunks from gitsigns (both staged and unstaged)
  local hunks = gitsigns.get_hunks(bufnr)
  
  if not hunks then
    return " "  -- Return padding space if no hunks
  end

  for _, hunk in ipairs(hunks) do
    local min_lnum = math.max(1, hunk.added.start)
    local max_lnum = math.max(1, hunk.added.start + math.max(0, hunk.added.count - 1))

    if lnum >= min_lnum and lnum <= max_lnum then
      local symbol = M.config.gitsigns.signs[hunk.type] or '│'
      
      -- Determine if this hunk is staged
      local is_staged = _G.is_line_staged(lnum, bufnr)
      
      -- Map hunk type to gitsigns highlight group
      local hl_name = hunk.type:sub(1, 1):upper() .. hunk.type:sub(2)
      
      -- Use staged highlight group if available and hunk is staged
      local hl_group = 'GitSigns' .. hl_name
      if is_staged then
        hl_group = 'GitSignsStaged' .. hl_name
      end
      
      -- Return symbol with color using %# syntax
      return '%#' .. hl_group .. '#' .. symbol .. '%*'
    end
  end

  -- Return padding space if line has no git changes
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
    if label ~= "" then -- lksdjfkls
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

         -- Integrate with gitsigns if available
         -- This ensures statuscolumn updates when gitsigns data changes
         if M.config.gitsigns.enabled then
           vim.api.nvim_create_autocmd("User", {
             group = group,
             pattern = "GitSignsUpdate",
             callback = update_status_column
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

  vim.opt.relativenumber = true
  create_auto_commands()
  M.enable_line_numbers()
end
--example of statuscolumnwithcolros!
-- vim.opt.statuscolumn = "%!v:lua.StatusColumn()"

-- -- Simple test: 3 parts with different colors
-- function _G.StatusColumn()
--   local linenr = vim.v.lnum
--   local hl1 = "LineNr"       -- default line number color
--   local hl2 = "LineNrRed"    -- odd line number color
--   local hl3 = "LineNrBlue"   -- fold/sign color

--   -- even line numbers blue, odd red, fold marker green
--   local number = string.format("%3d", linenr)
--   local part1 = "%#" .. hl1 .. "#" .. "│"       -- gutter symbol
--   local part2 = "%#" .. ((linenr % 2 == 0) and hl3 or hl2) .. "#" .. number
--   local part3 = "%#LineNrGreen#" .. " ▶"        -- dummy fold marker

--   return part1 .. part2 .. part3
-- end

-- -- Define colors
-- vim.cmd("highlight LineNrRed guifg=#ff5f87")
-- vim.cmd("highlight LineNrBlue guifg=#5fd7ff")
-- vim.cmd("highlight LineNrGreen guifg=#87ff87")

return M
