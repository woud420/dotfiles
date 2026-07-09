# Developer Context

## About Me

I work across multiple organizations and contexts. Do not assume knowledge or patterns from one project apply to another. Each project should be treated independently.

I use multiple AI assistants (Claude, Codex, Copilot, etc.) depending on the task. Keep responses practical and tool-agnostic.

## Languages (in order of preference)

1. **Rust** - backend, systems programming, CLI tools
2. **Python** - backend services, scripting, automation
3. **TypeScript** - frontend, full-stack when needed
4. **Bash** - scripting, automation (keep it simple)

## Frameworks

| Domain | Preferred |
|--------|-----------|
| Frontend | Next.js (TypeScript), React Native |
| Backend (Python) | Flask |
| Backend (Rust) | Actix-web |

## Project Structure Preferences

```
project/
├── src/              # Source code
├── tests/            # Tests
├── docker/           # Docker configs
├── k8s/              # Kubernetes manifests (if applicable)
├── infra/terraform/  # Infrastructure as code
├── architecture/     # Design documents
└── project/          # Project documentation
```

- Prefer **git submodules** over monorepos
- Keep infrastructure separate from application code
- Tests live in `tests/`, not alongside source

## Coding Style

- Be concise. Avoid over-engineering.
- No unnecessary abstractions for one-time operations
- Error handling only where it matters (system boundaries, external APIs)
- Comments only when logic isn't self-evident
- Prefer explicit over clever

## Tools I Use

- **Package managers**: pacman (Arch), Homebrew (macOS), apt (Debian/Ubuntu)
- **Containers**: Docker, Docker Compose
- **Orchestration**: Kubernetes (kubectl, k9s, helm)
- **Infrastructure**: Terraform
- **Shell**: zsh with custom functions
- **Editor**: Neovim, Cursor
- **Terminal**: Kitty
- **Search**: fzf, ripgrep, fd

## Communication Preferences

- Be direct. Skip pleasantries and excessive caveats.
- When I'm on a specific OS, give me commands for that OS only.
- Don't pad responses with alternatives unless I ask.
- If something is wrong, say so. I prefer correction over false agreement.
