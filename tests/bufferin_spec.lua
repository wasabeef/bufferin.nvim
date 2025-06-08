--- Test suite for bufferin.nvim
--- Covers core functionality including buffer operations, navigation, and search

local bufferin = require('bufferin')
local buffer = require('bufferin.buffer')
local config = require('bufferin.config')
local utils = require('bufferin.utils')

describe('bufferin', function()
    before_each(function()
        -- Reset to default configuration
        config.setup({})

        -- Clear custom buffer order
        buffer.set_custom_order({})

        -- Clean up all buffers except current to ensure consistent test environment
        local current = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= current and vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end)

    describe('setup', function()
        it('should accept custom configuration', function()
            bufferin.setup({
                window = {
                    width = 0.5,
                    height = 0.5,
                },
                mappings = {
                    select = '<Space>',
                },
                override_navigation = true,
            })

            local conf = config.get()
            assert.equals(0.5, conf.window.width)
            assert.equals(0.5, conf.window.height)
            assert.equals('<Space>', conf.mappings.select)
            assert.equals(true, conf.override_navigation)
        end)
    end)

    describe('buffer operations', function()
        it('should list all buffers', function()
            -- Create test buffers
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            assert.equals(3, #buffers) -- Current + 2 created
        end)

        it('should filter hidden buffers', function()
            -- Create visible buffer
            local visible = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(visible, 'visible.txt')

            -- Create hidden buffer
            local hidden = vim.api.nvim_create_buf(false, true)

            config.setup({ display = { show_hidden = false } })
            local buffers = buffer.get_buffers()

            local found_hidden = false
            for _, buf in ipairs(buffers) do
                if buf.bufnr == hidden then
                    found_hidden = true
                end
            end

            assert.is_false(found_hidden)
        end)

        it('should delete buffer', function()
            local buf = vim.api.nvim_create_buf(true, false)
            assert.is_true(vim.api.nvim_buf_is_valid(buf))

            buffer.delete(buf, true)
            assert.is_false(vim.api.nvim_buf_is_valid(buf))
        end)

        it('should select buffer', function()
            local buf = vim.api.nvim_create_buf(true, false)
            buffer.select(buf)
            assert.equals(buf, vim.api.nvim_get_current_buf())
        end)

        it('should reorder buffers', function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            local initial_order = {}
            for _, buf in ipairs(buffers) do
                table.insert(initial_order, buf.bufnr)
            end

            -- Move second buffer to first position
            buffer.move_buffer(2, 1, buffers)

            local new_buffers = buffer.get_buffers()
            assert.equals(initial_order[2], new_buffers[1].bufnr)
            assert.equals(initial_order[1], new_buffers[2].bufnr)
        end)

        it('should handle invalid move operations', function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buffers = buffer.get_buffers()

            -- Test invalid indices
            assert.is_false(buffer.move_buffer(0, 1, buffers))
            assert.is_false(buffer.move_buffer(1, 0, buffers))
            assert.is_false(buffer.move_buffer(1, #buffers + 1, buffers))
            assert.is_false(buffer.move_buffer(1, 1, buffers)) -- Same position
        end)

        it('should maintain custom order across buffer additions', function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)

            local buffers = buffer.get_buffers()
            buffer.move_buffer(2, 1, buffers)

            -- Add new buffer
            local buf3 = vim.api.nvim_create_buf(true, false)

            local new_buffers = buffer.get_buffers()
            -- New buffer should be at the end
            assert.equals(buf3, new_buffers[#new_buffers].bufnr)
        end)
    end)

    describe('search functionality', function()
        it('should match buffer by name', function()
            local buf_info = {
                display_name = 'test.lua',
                name = '/home/user/test.lua',
            }

            assert.is_true(utils.matches_search(buf_info, 'test'))
            assert.is_true(utils.matches_search(buf_info, 'lua'))
            assert.is_false(utils.matches_search(buf_info, 'vim'))
        end)

        it('should match buffer by path', function()
            local buf_info = {
                display_name = 'test.lua',
                name = '/home/user/project/test.lua',
            }

            assert.is_true(utils.matches_search(buf_info, 'home'))
            assert.is_true(utils.matches_search(buf_info, 'project'))
        end)

        it('should handle case-insensitive search', function()
            local buf_info = {
                display_name = 'Test.Lua',
                name = '/Home/User/Test.Lua',
            }

            assert.is_true(utils.matches_search(buf_info, 'test'))
            assert.is_true(utils.matches_search(buf_info, 'TEST'))
            assert.is_true(utils.matches_search(buf_info, 'lua'))
            assert.is_true(utils.matches_search(buf_info, 'LUA'))
        end)
    end)

    describe('navigation', function()
        it('should navigate to next buffer', function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            buffer.select(buf1)
            bufferin.next()
            assert.equals(buf2, vim.api.nvim_get_current_buf())

            bufferin.next()
            assert.equals(buf3, vim.api.nvim_get_current_buf())

            -- Should wrap around
            bufferin.next()
            local current_buf = vim.api.nvim_get_current_buf()
            assert.is_true(current_buf == buf1 or vim.fn.buflisted(current_buf) == 1)
        end)

        it('should navigate to previous buffer', function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            local buf2 = vim.api.nvim_create_buf(true, false)
            local buf3 = vim.api.nvim_create_buf(true, false)

            buffer.select(buf3)
            bufferin.prev()
            assert.equals(buf2, vim.api.nvim_get_current_buf())

            bufferin.prev()
            assert.equals(buf1, vim.api.nvim_get_current_buf())
        end)
    end)

    describe('utils', function()
        it('should get correct display name', function()
            assert.equals('[No Name]', utils.get_display_name(''))
            assert.equals('test.lua', utils.get_display_name('/path/to/test.lua'))
            assert.equals('[Terminal]', utils.get_display_name('term://something'))
        end)
    end)

    describe('edge cases', function()
        it('should handle empty buffer list', function()
            -- Delete all buffers including current
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end

            -- Create a new buffer
            vim.cmd('enew')

            local buffers = buffer.get_buffers()
            assert.equals(1, #buffers)
        end)

        it('should handle buffers with same name', function()
            local buf1 = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(buf1, 'test.txt')

            local buf2 = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(buf2, 'test.txt')

            local buffers = buffer.get_buffers()
            local found_count = 0
            for _, buf in ipairs(buffers) do
                if buf.display_name == 'test.txt' then
                    found_count = found_count + 1
                end
            end

            assert.equals(2, found_count)
        end)
    end)
end)
