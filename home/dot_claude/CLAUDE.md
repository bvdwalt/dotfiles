# General Rules

- Do NOT modify existing working code unless explicitly asked. When fixing a bug or adding a feature, limit changes to the specific area requested.
- Prefer the simplest approach first. Don't add Pydantic validators, complex abstractions, or over-engineered solutions when a simple inline fix suffices. Ask before choosing between approaches if unclear.

# Workflow

- Before making any changes, explain your hypothesis for the root cause and what evidence supports it. Wait for confirmation before editing code.
- When asked to implement something, read the relevant code and propose an implementation plan with specific files to change and the approach for each. Don't write any code until the plan is approved.
- When fixing a bug, first write a test that reproduces it and verify it fails. Then fix the code and verify the test passes. Do not modify any code that the failing test doesn't exercise.

# Docker

- When working with Docker containers, use `host.docker.internal` instead of `localhost` for host-to-container networking on macOS/Windows. Always verify Go version compatibility with the target base image.
