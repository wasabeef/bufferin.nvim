# Contributing to bufferin.nvim

Thank you for your interest in contributing to bufferin.nvim! This guide will help you get started with development and understand our contribution process.

## 🚀 Quick Start

### Prerequisites

- Neovim >= 0.7.0
- Lua 5.1+ (included with Neovim)
- Git
- Optional: [stylua](https://github.com/JohnnyMorganz/StyLua) for code formatting
- Optional: [luacheck](https://github.com/mpeterv/luacheck) for static analysis

### Development Setup

1. **Fork and Clone**

   ```bash
   git clone https://github.com/wasabeef/bufferin.nvim.git
   cd bufferin.nvim
   ```

2. **Set up Development Environment**

   ```bash
   # Install development dependencies (optional but recommended)
   # For formatting
   cargo install stylua
   
   # For static analysis
   luarocks install luacheck
   ```

3. **Create a Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🏗️ Project Structure

```
bufferin.nvim/
├── lua/bufferin/           # Core plugin modules
│   ├── init.lua           # Main entry point and setup
│   ├── config.lua         # Configuration management
│   ├── buffer.lua         # Buffer operations and plugin integration
│   ├── ui.lua             # User interface and window layout
│   ├── utils.lua          # Utility functions
│   └── icons.lua          # Icon provider management
├── plugin/bufferin.lua    # Vim plugin integration
├── doc/bufferin.txt       # Comprehensive documentation
├── tests/                 # Test suite
│   ├── minimal_init.lua   # Test environment setup
│   └── *.lua             # Individual test files
├── README.md              # Project overview
├── CONTRIBUTING.md        # This file
├── LICENSE               # MIT License
└── stylua.toml           # Code formatting configuration
```

## 🧪 Testing

### Running Tests

bufferin.nvim uses [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing.

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"

# Run specific test file
nvim --headless -u tests/minimal_init.lua -c "luafile tests/buffer_management_test.lua"

# Run tests with verbose output
nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests', {minimal_init = 'tests/minimal_init.lua'})"
```

### Writing Tests

When adding new features, please include comprehensive tests:

```lua
-- Example test structure
local buffer = require('bufferin.buffer')

describe('buffer management', function()
    before_each(function()
        -- Setup test environment
    end)
    
    after_each(function()
        -- Cleanup
    end)
    
    it('should handle buffer operations correctly', function()
        -- Test implementation
        assert.are.equal(expected, actual)
    end)
end)
```

## 🎨 Code Style

### Formatting

We use [stylua](https://github.com/JohnnyMorganz/StyLua) for consistent code formatting:

```bash
# Format all Lua files
stylua lua/

# Format specific file
stylua lua/bufferin/init.lua

# Check formatting without making changes
stylua --check lua/
```

### Style Guidelines

- **Indentation**: 4 spaces (configured in `stylua.toml`)
- **Line Width**: 120 characters maximum
- **Quotes**: Single quotes preferred for strings
- **Function Calls**: Always use parentheses
- **Documentation**: LuaLS-style annotations for all public functions

### Example Code Style

```lua
--- Process buffer list and return formatted data
--- @param buffers table List of buffer objects
--- @param options table|nil Optional configuration
--- @return table Processed buffer data
local function process_buffers(buffers, options)
    options = options or {}
    
    local result = {}
    for i, buffer in ipairs(buffers) do
        if buffer.valid then
            table.insert(result, {
                id = buffer.id,
                name = buffer.name,
                modified = buffer.modified,
            })
        end
    end
    
    return result
end
```

## 📝 Documentation

### Code Documentation

All public functions must include LuaLS-style documentation:

```lua
--- Brief description of the function
--- More detailed explanation if needed
--- @param param_name type Parameter description
--- @param optional_param type|nil Optional parameter description
--- @return type Return value description
function M.example_function(param_name, optional_param)
    -- Implementation
end
```

### Vim Help Documentation

When adding new features, update `doc/bufferin.txt`:

1. Add new sections following the existing structure
2. Include examples and use cases
3. Document all new configuration options
4. Add troubleshooting notes if applicable

## 🔧 Development Guidelines

### Code Organization

- **Modularity**: Each file should have a single, clear responsibility
- **Error Handling**: Use `pcall` for operations that might fail
- **Performance**: Cache expensive operations when possible
- **Compatibility**: Maintain Neovim >= 0.7.0 compatibility

### Plugin Integration

When adding support for new plugins:

1. **Detection**: Implement in `config.lua` using `pcall(require, 'plugin-name')`
2. **Graceful Fallback**: Always provide standalone functionality
3. **Testing**: Test with and without the target plugin
4. **Documentation**: Update integration documentation

### UI/UX Considerations

- **Responsiveness**: Handle various screen sizes and window configurations
- **Accessibility**: Support both mouse and keyboard navigation
- **Visual Consistency**: Follow Neovim's design patterns
- **Performance**: Minimize UI refresh operations

## 🐛 Bug Reports

When reporting bugs, please include:

### Bug Report Template

```
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- Neovim version: [e.g. 0.8.0]
- bufferin.nvim version: [e.g. v1.0.0]
- Operating System: [e.g. macOS 12.0]
- Terminal: [e.g. iTerm2, Windows Terminal]
- Other relevant plugins: [e.g. nvim-cokeline, bufferline.nvim]

**Configuration**
```lua
-- Your bufferin.nvim configuration
require('bufferin').setup({
    -- your config here
})
```

**Additional context**
Add any other context about the problem here.

```

## ✨ Feature Requests

### Feature Request Template

```

**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Other solutions or workarounds you've thought about.

**Additional context**
Any other context, mockups, or examples.

```

## 🚀 Pull Request Process

### Before Submitting

1. **Test Thoroughly**
   ```bash
   # Run full test suite
   nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"
   
   # Check code formatting
   stylua --check lua/
   
   # Run static analysis (optional)
   luacheck lua/
   ```

2. **Update Documentation**
   - Add/update function documentation
   - Update `README.md` if needed
   - Update `doc/bufferin.txt` for new features
   - Include examples in commit messages

3. **Follow Git Best Practices**
   - Use descriptive commit messages
   - Keep commits focused and atomic
   - Rebase on latest main before submitting

### Pull Request Template

```
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or breaking changes are documented)

## Related Issues
Fixes #(issue number)
```

### Review Process

1. **Automated Checks**: CI will run tests and style checks
2. **Code Review**: Maintainers will review your code
3. **Discussion**: Address any feedback or questions
4. **Approval**: Once approved, your PR will be merged

## 🎯 Areas for Contribution

### High Priority

- **Plugin Integrations**: Support for additional buffer line plugins
- **Performance**: Optimization for large buffer counts
- **Testing**: Expand test coverage for edge cases
- **Documentation**: Examples and tutorials

### Medium Priority

- **UI Enhancements**: Additional layout visualization modes
- **Accessibility**: Better keyboard navigation
- **Configuration**: More customization options
- **Internationalization**: Multi-language support

### Good First Issues

- **Icon Support**: Add support for additional file types
- **Bug Fixes**: Address reported issues
- **Documentation**: Fix typos, improve clarity
- **Code Cleanup**: Refactor deprecated patterns

## 💬 Communication

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Reviews**: Participate in pull request reviews
- **Community**: Help other users in discussions

## 📄 License

By contributing to bufferin.nvim, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be acknowledged in:

- Release notes for significant contributions
- README.md contributors section
- Git commit history

Thank you for contributing to bufferin.nvim! Your efforts help make buffer management better for the entire Neovim community.
