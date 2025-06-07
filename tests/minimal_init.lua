-- Minimal init file for running tests
-- This sets up the bare minimum Neovim configuration needed to run the test suite

-- Test environment paths
local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local plugin_dir = os.getenv("PLUGIN_DIR") or "."

-- Add test framework and plugin to runtime path
vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(plugin_dir)

-- Disable swap files and backups for cleaner test environment
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false

-- Load the test framework
vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")

-- Load the plugin being tested
require("bufferin")