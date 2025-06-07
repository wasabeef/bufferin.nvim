-- Luacheck configuration file for bufferin.nvim
-- Defines linting rules and exceptions

return {
    -- Global variables
    globals = {
        "vim",  -- Neovim global
    },
    -- Read-only globals (from test framework)
    read_globals = {
        "describe",     -- Test suite declaration
        "it",           -- Test case declaration
        "before_each",  -- Setup function
        "after_each",   -- Teardown function
        "assert",       -- Assertion library
        "pcall",        -- Protected call (Lua builtin)
    },
    -- Files to exclude from linting
    exclude_files = {
        ".luacheckrc",
        "tests/minimal_init.lua",  -- Test setup file
    },
    -- Maximum line length
    max_line_length = 120,
    -- Warnings to ignore
    ignore = {
        "212", -- Unused argument
        "213", -- Unused loop variable
    },
}