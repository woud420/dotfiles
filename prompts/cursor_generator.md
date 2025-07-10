# Prompt: Generate Language-Agnostic Cursor Rules from GitHub Project

## Task

Analyze the structure, patterns, and conventions used in the following GitHub repository:
`https://github.com/<org>/<repo>`

## Goal

Generate a **language-agnostic `CURSOR_RULES.md`** file that defines best practices, conventions, and expected structure for all future projects based on this example.

## Requirements

### 1. Modularity & Structure

* Identify and formalize the directory layout (e.g., `src/`, `tests/`, `api/`, `model/`, etc.).
* Define naming conventions for files, modules, and interfaces.

### 2. Build & Dev Tooling

* Extract and generalize Makefile targets, scripts, or dev tools used.
* Specify expectations for Docker/Kubernetes files, local development setup, and CI/CD scripts.

### 3. Documentation & Metadata

* Describe required documentation files such as `README.md` and an `architecture/` directory.
* Include a template or expected contents for the `architecture/` folder (e.g., flowcharts, mermaid diagrams, spec docs).

### 4. Testing Strategy

* Define structure and naming conventions for test files.
* Capture any patterns in unit vs. integration testing organization.

### 5. Design Principles

* Identify architectural or engineering principles in use (e.g., separation of concerns, single-responsibility).
* Outline abstraction patterns (DAO, repository, service layer, etc.) and layering guidelines.

### 6. Language-Agnostic Output

* Avoid tying rules to specific languages (like Rust, Python, TypeScript) unless absolutely necessary.
* Prefer role-based descriptions (e.g., "data model definition", "business logic layer") over language-specific implementation details.

## Format

* Output should be in **Markdown**.
* Use clear headings and bullet points.

