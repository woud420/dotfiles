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
- Infrastructure: Docker and Docker Compose, Kubernetes (kubectl, k9s, helm),
  Terraform, and Alchemy (alchemy.run) for TypeScript

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
- Commands for this machine's OS only (see "This machine" below) unless asked
  for alternatives
- Honest feedback over false validation

## Session Wrap-up

At the natural end of any substantive session (I say "wrap up", "done" or
"goodbye", or the work concludes), run the `session-review` skill before
finishing: verify that claimed outcomes actually happened, artifacts persisted
at all requested paths, knowledge was captured, and git, secret and privacy
hygiene held. Hand any improvement signals (a skill misfired, failed to
trigger, or needed re-explanation) to the `skill-improve` skill. At the start
of a session, offer to run `session-review` if the previous session did
substantive work and was not reviewed.
