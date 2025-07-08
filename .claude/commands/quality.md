Use git diff --name-only to identify changed files, then analyze for maintainability and cleanliness issues.
Focus Areas

Dead Code: Unreachable code, unused variables/functions/imports, commented-out blocks
Code Duplication: Repeated logic, similar functions, copy-paste patterns across files
Code Smells: Long functions, deep nesting, complex conditionals, magic numbers/strings
Naming & Structure: Unclear variable names, inconsistent conventions, poor file organization
Dependencies: Unused imports, outdated packages, circular dependencies

Output Format
[ISSUE TYPE] - [Description]

File: path/to/file.ext:line_number
Problem: Brief explanation of the quality issue
Impact: Why this affects maintainability
Fix: Specific refactoring suggestion

Focus on issues that genuinely impact code maintainability and team productivity.