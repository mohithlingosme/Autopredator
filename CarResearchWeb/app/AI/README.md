# AI Module

This module handles AI-powered features for Autopredator, including content generation, data enrichment, and validation.

## Structure

- `Prompts/`: Versioned prompt templates (see `Prompts/PromptRegistry.php`)
- `Chains/`: AI processing chains (orchestrations for multi-step flows)
- `Tools/`: Shared helpers (feature flags, utilities)
- `Validators/`: Validation logic for AI outputs
- `Logging/`: AI-specific logging and observability helpers

## Policies and Output Rules

- Canonical output rules live in `App\AI\OutputRules`: suggest-only, human approval required, and citations required.
- Trust-first, India-focused policies and disclaimers are documented in `AI_POLICY.md`.
- All AI outputs must remain suggestions and require human approval before publish or persistence.
- Citations (or explicit uncertainty) are required for factual claims.
