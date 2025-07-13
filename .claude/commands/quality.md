Use `git diff --name-only main...` to identify changed files. Read the entire file then analyze for maintainability and cleanliness issues.  Ignore files in the `.claude`, `docs`, `plan` directory. Also ignore `mix.exs`

Follow elixir patterns documented in @docs/elixir_conventions.md

Focus Areas

- Dead Code: Unreachable code, unused variables/functions/imports, commented-out blocks
Code Duplication: Repeated logic, similar functions, copy-paste patterns across files. Ignore single line duplications
- Code Smells: Long functions, deep nesting, complex conditionals, magic numbers/strings
- Redundant Code: Unnecessary pattern matching followed by immediate re-creation of same tuple/structure
- Naming & Structure: Unclear variable names, inconsistent conventions, poor file organization
- Dependencies: Unused imports, outdated packages, circular dependencies

Performance & Database Issues

- N+1 Database Queries: Multiple individual queries that could be combined into bulk operations
- Bulk Operations: Individual inserts/updates/deletes that should use Repo.insert_all/3, Repo.update_all/3, or similar bulk operations
- Inefficient Collection Lookups: Using `in` operator with lists instead of MapSet for membership checking (O(M×N) vs O(M+N))
- Inefficient Queries: Missing indexes, unnecessary JOINs, SELECT * usage, missing query optimization
- Database Transactions: Operations that should be wrapped in transactions for data consistency
- Eager Loading: Missing preload causing additional queries, or over-eager loading of unused associations

Phoenix/Web Specific

- Controller Bloat: Business logic in controllers instead of contexts
- View/Template Issues: Complex logic in templates, missing view helpers
- Route Organization: Poorly structured routes, missing route guards

Output Format
```md
\#[ORDERED ISSUE NUMBER] [ISSUE TYPE] - [Description]

File: path/to/file.ext:line_number
Problem: Brief explanation of the quality issue
Impact: Why this affects maintainability
Fix: Specific refactoring suggestion
```

Focus on issues that genuinely impact code maintainability and team productivity.