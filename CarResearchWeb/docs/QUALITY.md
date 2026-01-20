# Quality Strategy and Standards

## Quality Gates for Merge
- Lint and format pass.
- All tests (unit/integration) pass.
- Build (if applicable) succeeds.
- No high/critical security findings outstanding.

## Coding Standards
- Language: PHP 8.1+ (CLI + web). Prefer strict types and early returns.
- Structure: Keep app code under `app/` and `src/`; tests under `tests/`.
- Naming: Classes `PascalCase`, methods `camelCase`, constants `SNAKE_CASE`.
- Formatting: PSR-12 alignment; avoid trailing whitespace; 120 char soft wrap.
- Safety: Use `e()` for output escaping; never write to DB directly from AI flows.

## Branching and PR Rules
- Branches: `main` (stable), `develop` (integration), feature branches from `develop`.
- PRs: Target `develop` unless hotfix to `main`. Require one approval.
- Require CI to pass (lint + tests + build). Block merges on failing checks.
- Keep PRs scoped and linked to issues; include screenshots for UI changes.

## Coverage Targets
- Backend (PHP): minimum 80% line coverage on critical services and data loaders.
- Frontend (if/when added): minimum 70% line coverage on shared UI utilities/components.
- Gate coverage in CI reports; fail if thresholds are not met.

## Templates and Hygiene
- Use PR and issue templates in `.github/` for consistent reporting.
- Add test plan and risk notes in every PR.
