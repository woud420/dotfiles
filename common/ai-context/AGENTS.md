# Agent Context

This file provides context for AI coding assistants (Codex, Copilot, Claude, etc.).

## Developer Profile

- Works across multiple organizations — treat each project independently
- Uses multiple AI tools depending on task requirements

## Tech Stack

### Languages (preference order)
1. Rust - backend, systems, CLI tools
2. Python - backend, scripting, automation
3. TypeScript - frontend applications
4. Bash - simple scripts only

### Frameworks
- Frontend: Next.js (TypeScript), React Native
- Backend: Flask (Python), Actix-web (Rust)

### Infrastructure
- Containers: Docker, Docker Compose
- Orchestration: Kubernetes
- IaC: Terraform
- Package managers: pacman, Homebrew, apt (depending on OS)

## Code Style Guidelines

- Concise over verbose
- Explicit over clever
- No premature abstractions
- Comments only when logic isn't obvious
- Error handling at boundaries, not everywhere
- Tests in `tests/`, source in `src/`

## Project Structure

Preferred layout:
```
src/           - source code
tests/         - tests
docker/        - container configs
k8s/           - kubernetes manifests
infra/         - terraform and other IaC
architecture/  - design docs
```

Prefers git submodules over monorepos.

## Communication

- Direct responses, no filler
- OS-specific commands only (no multi-platform alternatives unless asked)
- Honest feedback over false validation
