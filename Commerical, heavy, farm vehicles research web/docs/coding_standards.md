# Coding Standards

This document outlines the coding standards and conventions for the Autopredator project.

## Python (Backend/API)

### Tools
- **Formatter**: Black
- **Import Sorter**: isort
- **Linter**: ruff
- **Type Checker**: mypy
- **Tester**: pytest

### Conventions
- Use snake_case for variables, functions, and methods
- Use PascalCase for classes
- Use UPPER_CASE for constants
- Line length: 88 characters (Black default)
- Use type hints for all function parameters and return values
- Use docstrings for all public functions and classes

### File Structure
```
apps/api/
├── main.py              # FastAPI app instance
├── config.py            # Configuration settings
├── database.py          # Database connection and models
├── routers/             # API route handlers
│   ├── vehicles.py
│   └── calculators.py
└── services/            # Business logic
    ├── vehicle_service.py
    └── calculator_service.py
```

## JavaScript/TypeScript (Frontend/Web)

### Tools
- **Linter**: ESLint
- **Formatter**: Prettier
- **Type Checker**: TypeScript (strict mode)
- **Tester**: Jest + React Testing Library

### Conventions
- Use camelCase for variables, functions, and methods
- Use PascalCase for components and classes
- Use UPPER_CASE for constants
- Line length: 80 characters
- Use TypeScript for all new code
- Use functional components with hooks
- Use meaningful component and variable names

### File Structure
```
apps/web/
├── pages/               # Next.js pages
│   ├── index.tsx
│   └── vehicles/
├── components/          # Reusable components
│   ├── VehicleCard.tsx
│   └── Calculator.tsx
├── hooks/               # Custom hooks
├── utils/               # Utility functions
└── styles/              # Global styles
```

## General Conventions

### Naming
- Use descriptive names that explain the purpose
- Avoid abbreviations unless they are well-known
- Use consistent naming across the codebase

### API Patterns
- Use RESTful conventions for endpoints
- Use JSON for request/response bodies
- Use HTTP status codes appropriately
- Include error messages in responses

### Commit Convention
Use Conventional Commits format:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Example: `feat: add EMI calculator to vehicle comparison`
