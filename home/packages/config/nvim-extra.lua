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

-- Suppress deprecation warnings for lspconfig and null-ls
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("lspconfig") or msg:match("null_ls") or msg:match("null%-ls") then
    return
  end
  notify(msg, ...)
end
