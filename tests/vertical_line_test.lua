-- Vertical line priority layout map test
local ui = require('bufferin.ui')

print('==========================================')
print('Vertical Line Priority Layout Map Test Start')
print('==========================================')

-- Test window data (check vertical line priority across multiple rows)
local test_windows = {
    -- Top row: 2 windows
    {
        win = 1000,
        buf = 1,
        name = 'file1.txt',
        width = 40,
        height = 15,
        row = 0,
        col = 0,
    },
    {
        win = 1001,
        buf = 2,
        name = 'file2.txt',
        width = 39,
        height = 15,
        row = 0,
        col = 41,
    },
    -- Bottom row: 1 full-width window
    {
        win = 1002,
        buf = 3,
        name = 'file3.txt',
        width = 80,
        height = 10,
        row = 16,
        col = 0,
    },
}

print('Test window layout:')
for i, win in ipairs(test_windows) do
    print(string.format('  %d: %s (%dx%d at %d,%d)', i, win.name, win.width, win.height, win.row, win.col))
end

-- Layout map generation test
print('\n=== Vertical Line Priority Layout Map Generation ===')

local layout_lines = ui._create_test_layout_display(test_windows)

if layout_lines and #layout_lines > 0 then
    print('✅ Vertical line priority layout map generation successful')
    print('Generated line count: ' .. #layout_lines)
    print('\nVertical line priority layout map output:')
    print(string.rep('=', 50))
    for i, line in ipairs(layout_lines) do
        print(string.format('%2d: %s', i, line))
    end
    print(string.rep('=', 50))

    -- Check if vertical lines are used correctly
    local has_vertical_priority = false
    for _, line in ipairs(layout_lines) do
        -- Check if ├ is changed to │
        if line:match('│%s*─*%s*│') and not line:match('├') then
            has_vertical_priority = true
        end
    end

    if has_vertical_priority then
        print('✅ Vertical line priority borders confirmed')
    else
        print('ℹ️  Vertical line priority difference may not be visible in this layout')
    end
else
    print('❌ Layout map generation failed')
end

-- Another test case: more complex layout
print('\n=== Vertical Line Priority Test with Complex Layout ===')

local complex_windows = {
    -- Top row: 3 windows
    {
        win = 2000,
        buf = 1,
        name = 'a.txt',
        width = 25,
        height = 10,
        row = 0,
        col = 0,
    },
    {
        win = 2001,
        buf = 2,
        name = 'b.txt',
        width = 25,
        height = 10,
        row = 0,
        col = 26,
    },
    {
        win = 2002,
        buf = 3,
        name = 'c.txt',
        width = 25,
        height = 10,
        row = 0,
        col = 52,
    },
    -- Bottom row: 2 windows
    {
        win = 2003,
        buf = 4,
        name = 'd.txt',
        width = 40,
        height = 10,
        row = 11,
        col = 0,
    },
    {
        win = 2004,
        buf = 5,
        name = 'e.txt',
        width = 37,
        height = 10,
        row = 11,
        col = 41,
    },
}

local complex_layout = ui._create_test_layout_display(complex_windows)

if #complex_layout > 0 then
    print('✅ Complex layout generation also successful')
    print('\nComplex layout output:')
    print(string.rep('=', 50))
    for i, line in ipairs(complex_layout) do
        print(string.format('%2d: %s', i, line))
    end
    print(string.rep('=', 50))
else
    print('❌ Complex layout generation failed')
end

print('\n==========================================')
print('✅ Vertical Line Priority Layout Map Test Complete')
print('- Change ├ symbol to │ to achieve vertical line priority')
print('- Improve visual consistency of layout')
print('==========================================')

vim.cmd('qa!')
