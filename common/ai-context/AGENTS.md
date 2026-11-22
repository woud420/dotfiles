# Agent Context

The dotfiles installer combines these shared instructions with this machine's
notes in each installed assistant's global instructions.

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

Run `session-review` at the natural end of every substantive session. At the
start of a session, offer `$session-review` if the previous session did
substantive work and missed its review. Pass any skill problems to `skill-improve`.

If `session-review` is unavailable on this machine, perform the review manually.
Verify claimed outcomes and requested artifacts, check Git and privacy hygiene,
and report any gaps. If `skill-improve` is unavailable, report skill problems
directly to the user.
