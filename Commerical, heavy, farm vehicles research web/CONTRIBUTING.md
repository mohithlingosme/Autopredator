# Contributing to AutoPredator FleetCommand

Thank you for your interest in contributing to FleetCommand! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. By participating, you agree to:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for mistakes
- Show empathy towards other contributors
- Help create a positive community

## Getting Started

### Prerequisites

- Docker & Docker Compose
- Node.js 18+ (for web development)
- Python 3.11+ (for API/worker development)
- Git

### Setup

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/your-username/fleetcommand.git
   cd fleetcommand
   ```

2. **Set up development environment:**
   ```bash
   ./scripts/bootstrap.sh
   ```

3. **Start services:**
   ```bash
   docker-compose up -d
   ```

4. **Verify setup:**
   - API: http://localhost:8000/docs
   - Web: http://localhost:3000

## Development Workflow

### Branch Naming

Use descriptive branch names following this pattern:

```
feature/add-user-authentication
bugfix/fix-vehicle-validation
docs/update-api-documentation
refactor/optimize-database-queries
```

### Commit Messages

Follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(auth): add JWT token refresh endpoint
fix(api): handle null values in vehicle creation
docs(api): update authentication examples
```

### Development Process

1. **Create a branch** from `main`
2. **Make changes** following coding standards
3. **Write tests** for new functionality
4. **Update documentation** if needed
5. **Run tests** locally
6. **Commit changes** with clear messages
7. **Push branch** and create pull request

## Pull Request Process

### Before Submitting

- [ ] Code follows project coding standards
- [ ] Tests pass locally
- [ ] Documentation is updated
- [ ] Commit messages are clear and descriptive
- [ ] Branch is up to date with `main`

### PR Template

Use the provided PR template with:

- **Description**: What changes were made and why
- **Type of Change**: Bug fix, feature, documentation, etc.
- **Testing**: How the changes were tested
- **Screenshots**: UI changes (if applicable)
- **Breaking Changes**: Any breaking changes

### Review Process

1. **Automated Checks**: CI/CD pipeline runs
2. **Code Review**: At least one maintainer reviews
3. **Testing**: QA team validates changes
4. **Approval**: Maintainers approve the PR
5. **Merge**: Squash merge with clean commit message

### PR Size Guidelines

- **Small PRs** (< 200 lines): Quick review, preferred
- **Medium PRs** (200-500 lines): May need multiple reviewers
- **Large PRs** (> 500 lines): Consider breaking into smaller PRs

## Coding Standards

### Python (Backend/API/Worker)

- Follow PEP 8 style guide
- Use type hints for function parameters and return values
- Write docstrings for all public functions and classes
- Use meaningful variable and function names
- Keep functions small and focused (single responsibility)

**Code Example:**
```python
from typing import Optional
from pydantic import BaseModel

class VehicleCreate(BaseModel):
    """Schema for creating a new vehicle."""
    registration_number: str
    vehicle_type: str
    make: str
    model: str
    year: int

def create_vehicle(
    org_id: str,
    vehicle_data: VehicleCreate,
    db: Session
) -> Vehicle:
    """Create a new vehicle for the organization.

    Args:
        org_id: Organization identifier
        vehicle_data: Vehicle creation data
        db: Database session

    Returns:
        Created vehicle instance

    Raises:
        ValidationError: If vehicle data is invalid
    """
    # Implementation here
    pass
```

### TypeScript/React (Frontend)

- Use TypeScript strict mode
- Follow React best practices
- Use functional components with hooks
- Implement proper error boundaries
- Write custom hooks for reusable logic

**Code Example:**
```typescript
interface Vehicle {
  id: string;
  registrationNumber: string;
  vehicleType: string;
  make: string;
  model: string;
  year: number;
}

interface UseVehiclesReturn {
  vehicles: Vehicle[];
  loading: boolean;
  error: string | null;
  refetch: () => void;
}

export function useVehicles(orgId: string): UseVehiclesReturn {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchVehicles = useCallback(async () => {
    try {
      setLoading(true);
      const response = await api.get(`/organizations/${orgId}/vehicles`);
      setVehicles(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch vehicles');
    } finally {
      setLoading(false);
    }
  }, [orgId]);

  useEffect(() => {
    fetchVehicles();
  }, [fetchVehicles]);

  return { vehicles, loading, error, refetch: fetchVehicles };
}
```

## Testing

### Testing Strategy

- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test API endpoints and database operations
- **E2E Tests**: Test complete user workflows
- **Load Tests**: Performance testing under load

### Running Tests

```bash
# Backend tests
cd apps/api
pytest

# Frontend tests
cd apps/web
npm test

# E2E tests
cd e2e
npm run test:e2e

# Load tests
cd load
k6 run load-test.js
```

### Test Coverage

Maintain minimum test coverage:
- Backend: 80% code coverage
- Frontend: 70% code coverage
- Critical paths: 90%+ coverage

## Documentation

### Documentation Standards

- Use Markdown for all documentation
- Keep documentation up to date with code changes
- Include code examples where helpful
- Document API endpoints with OpenAPI/Swagger

### Documentation Structure

```
docs/
├── Development_plan.md    # Development setup and workflow
├── Architecture.md        # System architecture
├── API.md                 # API reference
├── Data_model.md          # Database schema
├── Security.md            # Security guidelines
├── Deployment.md          # Deployment procedures
└── [feature]/             # Feature-specific docs
```

## Reporting Issues

### Bug Reports

Use the bug report template with:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Step-by-step reproduction steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: OS, browser, versions
- **Screenshots**: Visual evidence of the issue

### Feature Requests

Use the feature request template with:

- **Problem**: What problem are you trying to solve?
- **Solution**: Proposed solution
- **Alternatives**: Alternative approaches considered
- **Additional Context**: Any other relevant information

### Security Issues

For security vulnerabilities:

1. **DO NOT** create a public issue
2. Email security@company.com with details
3. Allow time for investigation before public disclosure

## Getting Help

- **Documentation**: Check docs/ directory first
- **Issues**: Search existing issues on GitHub
- **Discussions**: Use GitHub Discussions for questions
- **Slack**: Join our community Slack workspace

## Recognition

Contributors are recognized through:
- GitHub contributor statistics
- Release notes mentions
- Contributor spotlight in newsletters
- Invitation to contributor meetings

Thank you for contributing to FleetCommand! 🚛✨
