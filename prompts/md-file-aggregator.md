Prompt: Synthesize Global Architecture Rules from Cursor-Generated Files

Task

Take N Cursor-generated CURSOR_RULES.md files (or similar project rules files) that were generated from different language-specific projects and extract the universal, language-agnostic principles they share about how to structure a high-quality software project.

Input

N markdown files, each containing project conventions for a specific codebase.

Goal

Produce a single summary file that distills the core architectural patterns, project structure conventions, and engineering principles found across the different languages and repositories.

Requirements

1. Abstract Over Language

Focus on intent and design principles rather than syntax or language-specific idioms.

2. Identify Convergent Patterns Without Preset Assumptions

Carefully analyze each file on its own terms. Do not assume any fixed directory layout, naming convention, or modular structure.Instead, surface the organic overlaps and recurring themes in how these projects are structured and described—whether in how they organize source files, define responsibilities, manage dependencies, or encapsulate logic.

3. Normalize Testing Strategy

Identify shared principles in how testing is approached: test organization, naming conventions, test types, and what testing is expected to cover.

4. Summarize Core Engineering Beliefs

Abstract the shared philosophy across projects, including patterns of modularity, encapsulation, dependency management, and clarity of responsibilities. Include any implicit or explicit principles related to maintainability, scale, or team practices.

5. Output Format

Markdown with clear headings and bullet points

Prioritize clarity, conciseness, and general applicability

Avoid repeating language-specific patterns unless they clarify a higher-order principle
