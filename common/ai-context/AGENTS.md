# Agent Context

Shared instructions for AI coding assistants. The dotfiles installer writes
this file, followed by notes about the current machine, into each installed
assistant's global instructions (`~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`).

## Developer Profile

- Works across multiple organizations: treat each project independently and
  don't carry assumptions between repos or contexts
- Uses multiple AI tools depending on task requirements

## Tech Stack

Languages, in order of preference:

1. Rust: backend, systems, CLI tools
2. Python: backend, scripting, automation
3. TypeScript: frontend and backend
4. Bash: simple scripts only

- Frameworks: Vite or anything else Cloudflare-friendly, and React Native
  (frontend); FastAPI (Python backend); Actix-web (Rust backend)
- Infrastructure: Docker and Docker Compose, Kubernetes (kubectl, k9s, helm)
- Infrastructure as code: Alchemy (alchemy.run) for TypeScript projects,
  Terraform otherwise

## Code Style

- Concise over verbose; explicit over clever
- No premature abstractions; start with the minimal working solution
- Comments only when the logic isn't obvious
- Error handling at system boundaries, not everywhere

## Project Layout

```
src/              source code
tests/            tests
docker/           container configs
k8s/              kubernetes manifests
infra/terraform/  infrastructure as code
architecture/     design docs
```

- Prefer git submodules over monorepos
- Keep infrastructure separate from application code

## Communication

- Direct responses: no filler or excessive caveats
- Commands for this machine's OS only (see "Machine" below) unless asked
  for alternatives
- Honest feedback over false validation

## Session Wrap-up

At the end of a substantive session, run the `session-review` skill and pass
any skill problems it finds to `skill-improve`.
