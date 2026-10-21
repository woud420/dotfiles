# Documentation

Start with [installation](operations/installation.md) to set up a machine,
[customization](operations/customization.md) to adapt it, or
[maintenance](operations/maintenance.md) to check drift and recover files.

## Categories

| Folder | Purpose |
| --- | --- |
| [Architecture](architecture/README.md) | Current structure, platform boundaries, and installation flow |
| [Contracts](contracts/README.md) | Current observable behavior: modes, managed files, and configuration |
| [Decisions](decisions/README.md) | Accepted or durably rejected choices, rationale, and consequences |
| [Ideas](ideas/README.md) | Unimplemented proposals and experiments |
| [Operations](operations/README.md) | Repeatable setup, development, validation, maintenance, and recovery procedures |

## Common tasks

- [Choose an installation mode](operations/installation.md#choose-a-mode).
- [Find the source of an installed file](contracts/configuration.md).
- [Keep machine-specific settings local](operations/customization.md#local-overrides).
- [Initialize or update private skills](operations/private-skills.md).
- [Inspect a backup or restore a file](operations/maintenance.md#restore-a-file).
- [Verify a repository change](operations/validation.md).
- [Set up the Arch desktop](operations/arch-desktop.md).

## Naming and lifecycle

Use `docs/<category>/<descriptive-topic>.md`, with lowercase kebab-case names
and one durable subject per document. Reserve `README.md` for indexes and
orientation. Put status in the document rather than dates, authors, or
`draft`/`final`/`latest` suffixes in filenames.

Document current structure in architecture, behavior in contracts, and procedures
in operations. Put proposals in ideas; when resolved, move and rewrite them in
decisions, updating links. Keep one current document for each topic.

The [machine-convergence decision](decisions/machine-convergence.md) links to
historical planning records. Their retired paths and commands describe the old
design; use operations for current instructions.
