Use `git diff --name-only main...` to identify changed files. Read the entire file then analyze for maintainability and cleanliness issues.  Ignore files in the `.claude`, `docs`, `plan` directory. Also ignore `mix.exs`

Follow elixir patterns documented in @docs/elixir_conventions.md

Focus Areas

Dead Code: Unreachable code, unused variables/functions/imports, commented-out blocks
Code Duplication: Repeated logic, similar functions, copy-paste patterns across files
Code Smells: Long functions, deep nesting, complex conditionals, magic numbers/strings
Naming & Structure: Unclear variable names, inconsistent conventions, poor file organization
Dependencies: Unused imports, outdated packages, circular dependencies

Output Format
```md
\#[ORDERED ISSUE NUMBER] [ISSUE TYPE] - [Description]

File: path/to/file.ext:line_number
Problem: Brief explanation of the quality issue
Impact: Why this affects maintainability
Fix: Specific refactoring suggestion
```

Focus on issues that genuinely impact code maintainability and team productivity.