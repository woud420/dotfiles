# Claude Code Context

## Machine Context

Two files describe the current machine:
- `~/MACHINE.md` — static: what this machine is *for*, preferences, paths
- `~/MACHINE-STATE.md` — generated: what's actually installed, versions, recent packages

If you need current system info, check MACHINE-STATE.md or run commands directly.

## General Preferences

I work across multiple organizations. Treat each project independently — don't carry assumptions between repos or contexts.

## Languages & Frameworks

**Preferred stack:**
- Rust (backend, systems, CLI)
- Python (backend, scripting)
- TypeScript (frontend)
- Bash (simple automation only)

**Frameworks:** Next.js, React Native, Flask, Actix-web

## Project Conventions

- Source in `src/`, tests in `tests/`
- Git submodules over monorepos
- Infrastructure in `docker/`, `k8s/`, `infra/terraform/`

## How to Work With Me

- Be direct. No fluff, no excessive caveats.
- Give me commands for my current OS only (check MACHINE.md).
- Don't over-engineer. Minimal viable solution first.
- If I'm wrong, tell me. I value correction over validation.
- Skip emojis unless I use them first.

## Dotfiles

My dotfiles are at `~/workspace/dotfiles`. If you need to understand my shell setup, git aliases, or tooling, look there.
