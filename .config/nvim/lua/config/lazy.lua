local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json"
vim.fn.mkdir(vim.fn.stdpath("state"), "p")

require("lazy").setup({
  lockfile = lockfile,
  spec = {
    { import = "plugins" },
  },
  checker = { enabled = true },
})
