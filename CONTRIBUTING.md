# Contributing to bufferin.nvim

First off, thank you for considering contributing to bufferin.nvim!

## Ways to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- Neovim version (`nvim --version`)
- bufferin.nvim configuration
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error messages (if any)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- Use case for the feature
- Proposed solution
- Alternative solutions considered
- Additional context

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Add tests for any new functionality
3. Ensure the test suite passes
4. Make sure your code follows the existing style
5. Write a clear commit message

## Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/your-username/bufferin.nvim.git
   cd bufferin.nvim
   ```

2. Install development dependencies:
   - [luacheck](https://github.com/mpeterv/luacheck) for linting
   - [stylua](https://github.com/JohnnyMorganz/StyLua) for formatting
   - [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing

3. Run tests:
   ```bash
   nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"
   ```

4. Run linter:
   ```bash
   luacheck lua/
   ```

5. Format code:
   ```bash
   stylua lua/
   ```

## Code Style

- Use 4 spaces for indentation
- Follow the existing code style
- Add comments for complex logic
- Keep functions small and focused
- Use descriptive variable names

## Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Test with both stable and nightly Neovim

## Documentation

- Update README.md if adding new features
- Update help documentation in doc/
- Add inline comments for complex code
- Include examples where appropriate

## Commit Messages

- Use clear and meaningful commit messages
- Start with a verb in present tense
- Keep the first line under 50 characters
- Add detailed description if needed

Example:
```
Add search highlighting feature

- Highlight matching characters in buffer names
- Add configuration option to disable highlighting
- Update documentation with new feature
```

Thank you for contributing!