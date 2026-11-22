# Agent Context

Shared instructions for AI coding assistants. The dotfiles installer writes
this file, followed by notes about the current machine, into each installed
assistant's global instructions (`~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`).

## About Me

- I work across multiple organizations. Treat each project independently and
  don't carry assumptions between repos or contexts.

## Tech Stack

Languages, in order of preference:

1. Rust: backend, systems, CLI tools
2. Python: backend, scripting, automation
3. TypeScript: frontend
4. Bash: simple scripts only

- Frameworks: Next.js and React Native (frontend), Flask (Python backend),
  Actix-web (Rust backend)
- Infrastructure: Docker and Docker Compose, Kubernetes (kubectl, k9s, helm),
  Terraform

## Code Style

- Concise over verbose; explicit over clever
- No premature abstractions; start with the minimal working solution
- Comments only when the logic isn't obvious
- Error handling at system boundaries, not everywhere

## Project Layout

```
src/              source code
tests/            tests (not alongside source)
docker/           container configs
k8s/              Kubernetes manifests
infra/terraform/  infrastructure as code
architecture/     design docs
```

- Prefer git submodules over monorepos
- Keep infrastructure separate from application code

## How to Work With Me

- Be direct: no filler or excessive caveats
- Give commands for this machine's OS only (see "This machine" below) unless I
  ask for alternatives
- If I'm wrong, say so; I prefer correction over agreement
- No emojis unless I use them first

## Dotfiles

My dotfiles are github.com/woud420/dotfiles, checked out at the path given
under "This machine". Look there for my shell setup, git aliases and tooling.

## Session Wrap-up

At the natural end of any substantive session (I say "wrap up", "done" or
"goodbye", or the work concludes), run the `session-review` skill before
finishing: verify that claimed outcomes actually happened, artifacts persisted
at all requested paths, knowledge was captured, and git, secret and privacy
hygiene held. Hand any improvement signals (a skill misfired, failed to
trigger, or needed re-explanation) to the `skill-improve` skill. At the start
of a session, offer to run `session-review` if the previous session did
substantive work and was not reviewed.
