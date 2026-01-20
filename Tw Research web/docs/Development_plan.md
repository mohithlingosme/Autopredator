# Development Plan

This document outlines the development guidelines, branching strategy, and engineering standards for the Autopredator monorepo.

## Branching Strategy

- `main`: Production-ready code
- `dev`: Development branch for integration
- `feature/*`: Feature branches
- `bugfix/*`: Bug fix branches
- `release/*`: Release preparation branches

### Branch Protection Rules

- `main` and `dev` branches require:
  - Pull request reviews (at least 1 reviewer)
  - Status checks to pass (lint, test, build)
  - No direct pushes allowed

## Commit Conventions

Use Conventional Commits:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation
- `style:` for formatting
- `refactor:` for code restructuring
- `test:` for tests
- `chore:` for maintenance

## Definition of Done

- Code is reviewed and approved
- Tests pass
- Linting passes
- Documentation updated
- No critical security issues

## Code Quality Standards

- Follow ESLint rules for JavaScript/TypeScript
- Use Ruff, Black, and MyPy for Python
- Maintain test coverage above 60%
- Use meaningful variable and function names
- Add comments for complex logic

## Pull Request Process

1. Create feature branch from `dev`
2. Make changes with proper commits
3. Push branch and create PR
4. Ensure CI passes
5. Get review and approval
6. Merge to `dev` (squash commits)
7. Delete feature branch

## Release Process

1. Create release branch from `dev`
2. Update version numbers
3. Update CHANGELOG.md
4. Merge to `main`
5. Tag release
6. Deploy to production
