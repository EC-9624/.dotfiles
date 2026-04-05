vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25

local group = vim.api.nvim_create_augroup("dotfiles_netrw", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "netrw",
  callback = function(event)
    vim.keymap.set("n", "l", "<CR>", {
      buffer = event.buf,
      silent = true,
      desc = "Open entry",
    })
  end,
})
