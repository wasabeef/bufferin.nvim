-- bufferin.nvim
-- A simple and intuitive buffer manager for Neovim
-- Repository: https://github.com/wasabeef/bufferin.nvim
-- License: MIT

-- Check Neovim version compatibility
if vim.fn.has('nvim-0.7.0') ~= 1 then
    vim.api.nvim_err_writeln('bufferin.nvim requires Neovim 0.7.0+')
    return
end

-- Register user commands

-- Open/toggle the buffer manager window
vim.api.nvim_create_user_command('Bufferin', function()
    require('bufferin').toggle()
end, { desc = 'Toggle bufferin window' })

