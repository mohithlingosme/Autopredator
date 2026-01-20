# Contributing to Autopredator

Thank you for your interest in contributing to Autopredator! We welcome contributions from the community.

## Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. By participating, you agree to:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for mistakes
- Show empathy towards other contributors

## How to Contribute

### 1. Fork the Repository

Fork the repository on GitHub and clone your fork locally.

```bash
git clone https://github.com/your-username/autopredator.git
cd autopredator
```

### 2. Set Up Development Environment

Follow the setup instructions in the README.md file.

### 3. Create a Feature Branch

Create a branch for your changes:

```bash
git checkout -b feature/your-feature-name
```

Use descriptive branch names following the pattern:
- `feature/description` for new features
- `bugfix/description` for bug fixes
- `docs/description` for documentation
- `refactor/description` for code refactoring

### 4. Make Changes

- Write clear, concise commit messages using Conventional Commits
- Ensure your code follows the project's style guidelines
- Add tests for new functionality
- Update documentation as needed

### 5. Run Tests and Checks

Before submitting, ensure all checks pass:

```bash
# Run linting
npm run lint

# Run tests
npm run test

# Run type checking
npm run typecheck

# For Python code
ruff check
black --check .
mypy .
pytest
```

### 6. Commit Your Changes

Use Conventional Commits format:

```bash
git commit -m "feat: add new comparison feature"
git commit -m "fix: resolve memory leak in data processing"
git commit -m "docs: update API documentation"
```

### 7. Push and Create Pull Request

Push your branch and create a pull request:

```bash
git push origin feature/your-feature-name
```

### 8. Pull Request Process

- Provide a clear description of the changes
- Reference any related issues
- Ensure CI checks pass
- Request review from appropriate team members
- Address review feedback

## Development Guidelines

### Code Style

- Follow ESLint rules for JavaScript/TypeScript
- Use Black for Python code formatting
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Testing

- Write unit tests for new functionality
- Maintain test coverage above 60%
- Test edge cases and error conditions
- Use descriptive test names

### Documentation

- Update README.md for significant changes
- Add JSDoc/TSDoc comments for public APIs
- Update relevant documentation files
- Keep examples up to date

## Issue Reporting

When reporting bugs or requesting features:

- Use the appropriate issue template
- Provide clear steps to reproduce
- Include environment details
- Add screenshots for UI issues
- Specify expected vs. actual behavior

## Getting Help

- Check existing issues and documentation first
- Join our community discussions
- Contact the maintainers for guidance

Thank you for contributing to Autopredator!
