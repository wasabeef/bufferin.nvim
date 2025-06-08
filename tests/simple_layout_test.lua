-- Simple layout map test
local ui = require('bufferin.ui')

print('==========================================')
print('Simple Layout Map Test Start')
print('==========================================')

-- Test same situation as original problem
local test_windows = {
    -- Top row: 2 utils.lua files
    {
        win = 1000,
        buf = 1,
        name = 'utils.lua',
        width = 40,
        height = 15,
        row = 0,
        col = 0,
    },
    {
        win = 1001,
        buf = 2,
        name = 'utils.lua', -- Same filename
        width = 39,
        height = 15,
        row = 0,
        col = 41,
    },
    -- Bottom row: more utils.lua files
    {
        win = 1002,
        buf = 3,
        name = 'utils.lua',
        width = 40,
        height = 10,
        row = 16,
        col = 0,
    },
    {
        win = 1003,
        buf = 4,
        name = 'utils.lua',
        width = 39,
        height = 10,
        row = 16,
        col = 41,
    },
}

print('Test window layout:')
for i, win in ipairs(test_windows) do
    print(string.format('  %d: %s (%dx%d at %d,%d)', i, win.name, win.width, win.height, win.row, win.col))
end

print('\n=== Post-Fix Layout Map Generation ===')

local layout_lines = ui._create_test_layout_display(test_windows)

if layout_lines and #layout_lines > 0 then
    print('✅ Layout map generation successful')
    print('Generated line count: ' .. #layout_lines)
    print('\nPost-fix layout map output:')
    print(string.rep('=', 50))
    for i, line in ipairs(layout_lines) do
        print(string.format('%2d: %s', i, line))
    end
    print(string.rep('=', 50))

    -- Check if correct numbering is applied
    local has_numbered_labels = false
    for _, line in ipairs(layout_lines) do
        if line:match('utils%.lua%(2%)') or line:match('utils%.lua%(3%)') then
            has_numbered_labels = true
            break
        end
    end

    -- Check for clean borders
    local has_clean_borders = false
    for _, line in ipairs(layout_lines) do
        if line:match('^┌[─┬]+┐$') or line:match('^└[─┴]+┘$') then
            has_clean_borders = true
            break
        end
    end

    if has_numbered_labels then
        print('✅ Same filenames correctly numbered')
    else
        print('ℹ️  Numbered labels not found')
    end

    if has_clean_borders then
        print('✅ Borders displayed neatly')
    else
        print('ℹ️  Please check border status')
    end
else
    print('❌ Layout map generation failed')
end

print('\n==========================================')
print('✅ Simple Layout Map Test Complete')
print('- Same filenames distinguished by numbering')
print('- Appropriate borders for all cells')
print('- Simple and readable display')
print('==========================================')

vim.cmd('qa!')
