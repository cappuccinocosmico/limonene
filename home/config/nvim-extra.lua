-- Use system clipboard for yank/paste
vim.opt.clipboard:append("unnamedplus")

-- Tab spacing configuration (2 spaces)
vim.opt.tabstop = 2        -- Number of spaces a tab character displays as
vim.opt.shiftwidth = 2     -- Number of spaces for each indent level
vim.opt.softtabstop = 2    -- Number of spaces for <Tab> key press
vim.opt.expandtab = true   -- Convert tabs to spaces

-- Auto-reload files when they change on disk
vim.opt.autoread = true

-- Trigger autoread when files change (check every 4 seconds and on events)
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

-- Notification after file change
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

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

-- Enable spell check for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"markdown", "md"},
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- Set custom orange color for dashboard header
local dashboard_header_color = "#ec9d7a" -- softer coral orange

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = dashboard_header_color, bold = true })
  end,
})

-- Set it immediately as well
vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = dashboard_header_color, bold = true })
