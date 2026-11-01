-- shit I dont understand to get copy and paste working over ssh, uses some escape sequence stuff I don't really care to learn atm, will fix if it breaks - nic
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
end


-- YAY autosaving - nic
-- Autosave active buffer every 5 minutes
-- Only saves if:
-- 1. Buffer is modifiable and has a file name
-- 2. Buffer has unsaved changes
-- 3. File on disk hasn't been modified by another process
local autosave_timer = vim.loop.new_timer()
local autosave_interval = 5 * 60 * 1000 -- 5 minutes in milliseconds

-- Track if we're in the middle of a FileChangedShell event
local file_changed_on_disk = {}

-- Mark files that have changed on disk
vim.api.nvim_create_autocmd("FileChangedShell", {
  pattern = "*",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename ~= "" then
      file_changed_on_disk[filename] = true
      vim.notify("File changed on disk: " .. vim.fn.fnamemodify(filename, ":t"), vim.log.levels.WARN)
    end
  end,
})

-- Clear the flag when user explicitly reloads or saves
vim.api.nvim_create_autocmd({"BufRead", "BufWrite"}, {
  pattern = "*",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename ~= "" then
      file_changed_on_disk[filename] = nil
    end
  end,
})

-- Autosave function
local function autosave_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- Skip if buffer has no filename
  if filename == "" then
    return
  end

  -- Skip if buffer is not modifiable
  if not vim.api.nvim_buf_get_option(bufnr, 'modifiable') then
    return
  end

  -- Skip if buffer has no unsaved changes
  if not vim.api.nvim_buf_get_option(bufnr, 'modified') then
    return
  end

  -- Skip if file was changed on disk by another process
  if file_changed_on_disk[filename] then
    vim.notify("Autosave skipped: " .. vim.fn.fnamemodify(filename, ":t") .. " was modified externally", vim.log.levels.WARN)
    return
  end

  -- Check if file on disk changed before saving
  vim.cmd('checktime')

  -- If checktime triggered FileChangedShell, the flag would be set, so check again
  if file_changed_on_disk[filename] then
    vim.notify("Autosave skipped: " .. vim.fn.fnamemodify(filename, ":t") .. " was modified externally", vim.log.levels.WARN)
    return
  end

  -- Save the buffer
  local ok, err = pcall(function()
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd('silent! write')
    end)
  end)

  if ok then
    vim.notify("Autosaved: " .. vim.fn.fnamemodify(filename, ":t"), vim.log.levels.INFO)
  else
    vim.notify("Autosave failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- Start the autosave timer
autosave_timer:start(autosave_interval, autosave_interval, vim.schedule_wrap(autosave_current_buffer))
