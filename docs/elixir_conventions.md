
# Frontend

## Running

- Never run `npm run dev`. You can assume that is already running in a `Frontend` terminal
- Test type checking with `npm run type-check`
- The frontend runs on http://localhost:5173
- In development there is a user with username: "admin@example.com", password: "adminpassword"
- You never have to refresh the page, there is hot reloading in development

## XHR Requests

- All API ineractions should be in /frontendapps/lib/api-client
- Never use `fetch` in a component. Always use the appropriate {feature}\_api.ts file
- Create a new /frontendapps/lib/api-client/{feature}\_api.ts and /frontendapps/lib/api-client/{feature}\_types.ts for new features

## Phoenix Channels

- Do not use phoenix channels when a regular xhr request works
- phoenix channels should be for situations where we are streaming responses or asynchronously sending multiple responses
- use frontend/src/lib/channels/useChannel.ts for the basis of any new feature that will use phoenix channels

## Testing

- use the playwright mcp tools when available to test ui changes
- use `npm run type-check` to test the types

# Backend

## Naming

- `Logbook` is the main elixir module. All modules should start with `Logbook.` or `LogbookWeb.`

## Error handling

- functions should return `{:error, "error_reason"}` when an error occurs
- Do not use `try` `catch` or `rescue`. Explanation from the elixir docs:

  ```
  source: https://hexdocs.pm/elixir/try-catch-and-rescue.html#fail-fast-let-it-crash
  Fail fast / Let it crash
  One saying that is common in the Erlang community, as well as Elixir's, is "fail fast" / "let it crash". The idea behind let it crash is that, in case something unexpected happens, it is best to let the exception happen, without rescuing it.

  It is important to emphasize the word unexpected. For example, imagine you are building a script to process files. Your script receives filenames as inputs. It is expected that users may make mistakes and provide unknown filenames. In this scenario, while you could use File.read!/1 to read files and let it crash in case of invalid filenames, it probably makes more sense to use File.read/1 and provide users of your script with a clear and precise feedback of what went wrong.

  Other times, you may fully expect a certain file to exist, and in case it does not, it means something terribly wrong has happened elsewhere. In such cases, File.read!/1 is all you need.

  The second approach also works because, as discussed in the Processes chapter, all Elixir code runs inside processes that are isolated and don't share anything by default. Therefore, an unhandled exception in a process will never crash or corrupt the state of another process. This allows us to define supervisor processes, which are meant to observe when a process terminates unexpectedly, and start a new one in its place.

  At the end of the day, "fail fast" / "let it crash" is a way of saying that, when something unexpected happens, it is best to start from scratch within a new process, freshly started by a supervisor, rather than blindly trying to rescue all possible error cases without the full context of when and how they can happen.
  ```

- AGAIN NEVER USE `try` `catch` or `rescue`. Read the Explanation above

## Running the Server

- Never try to start the api with `mix phx.server` or `iex -S mix phx.server`. You can assume the server is already running in an `Elixir Backend` terminal
- NEVER RUN `iex`
- You never need to restart the server, it recompiles on the next web request
- Run `mix compile` to see if it compiles
  - Always fix any warnings that come up during compilation

## Ecto

### Avoid unnecessary preloads

- DO NOT add preloads for associations that aren't needed. Double check that all preloads are needed
- If a function exists to pull the entity you need but it preloads tables you don't need, create a new function with a query just for what you need.
- Never preload associations while mapping over a list
- Prefer selecting just the fields needed instead of the whole schema

### Preferred Query Syntax

Use the `from()` macro syntax for all Ecto queries instead of the pipe-based approach. This provides better readability and a more declarative style.

#### ✅ Preferred Style

```elixir
def list_projects(user_id, filters \\ %{}) do
  from(p in Project,
    join: pu in ProjectUser,
    on: pu.project_uid == p.uid,
    where: pu.user_id == ^user_id,
    where: not p.is_deleted,
    preload: [:project_status, :created_by, :updated_by],
    order_by: [desc: p.inserted_at]
  )
  |> apply_filters(filters)
  |> Repo.all()
end

def get_project!(uid) do
  from(p in Project,
    where: p.uid == ^uid and not p.is_deleted,
    preload: [:project_status, :created_by, :updated_by]
  )
  |> Repo.one!()
end
```

#### ❌ Avoid This Style

```elixir
def list_projects(user_id, filters \\ %{}) do
  Project
  |> where([p], not p.is_deleted)
  |> join(:inner, [p], pu in ProjectUser, on: pu.project_uid == p.uid)
  |> where([p, pu], pu.user_id == ^user_id)
  |> preload([:project_status, :created_by, :updated_by])
  |> order_by([p], desc: p.inserted_at)
  |> Repo.all()
end
```

### Key Benefits

1. **Declarative**: All query components are defined upfront in the `from()` block
2. **Readable**: Easier to scan and understand the query structure
3. **Consistent**: Uniform style across all queries in the codebase
4. **Maintainable**: Clear separation between core query logic and additional processing

### Guidelines

- Use `from()` for the main query structure
- Include `where`, `join`, `preload`, `order_by`, `select` etc. inside the `from()` block
- Join using `assoc`'s instead of `on` clauses when possible
- Chain additional processing (like filters, pagination) after the `from()` block using pipes
- Always use meaningful variable names for bindings (e.g., `p` for Project, `pu` for ProjectUser)
- Always alias the tables when they will be reused(e.g., `as: :project` for Project, `as: :project_user` for ProjectUser)

### Examples

#### Simple Query

```elixir
from(u in User,
  where: not u.is_deleted,
  order_by: [asc: u.username]
)
|> Repo.all()
```

#### Complex Query with Joins

```elixir
from(p in Project,
  as: :project,
  join: pu in assoc(p, :project_user),
  as: :project_user,
  join: u in assoc(pu, :user),
  where: u.id == ^user_id,
  where: not p.is_deleted,
  preload: [:project_status, users: [:user]],
  order_by: [desc: p.inserted_at]
)
|> apply_filters(filters)
|> Repo.all()
```

#### Subqueries

```elixir
existing_ids_query =
  from pu in ProjectUser,
    where: pu.project_uid == ^project_uid,
    select: pu.user_id

from(u in User,
  where: not u.is_deleted,
  where: u.id not in subquery(existing_ids_query)
)
|> Repo.all()
```

#### Migrations

- Group all requested db changes into a single migration (do not create a migration file per table)
- Create the migration file with `mix ecto.gen.migration feature_ore_table_description`
- Always use `:text` for string columns (They will be `:string` in schemas)
- Always use `:jsonb` for json columns (They will be `:map` in schemas)
- Always set a default timestamp: `timestamps(default: fragment("now()"))`

## API

### Controllers

Controllers must follow strict patterns for error handling and response formatting:

#### Error Handling Pattern

- **MANDATORY**: Use `with` statements for all business logic operations
- **NEVER** include `else` clauses in `with` statements - let the fallback controller handle all errors
- **NEVER** use `case` statements for error handling in controller actions
- **NEVER** manually handle `{:error, ...}` tuples in controller actions
- All controller actions must declare `action_fallback AHAWeb.FallbackController`

#### ✅ Correct Pattern

```elixir
def create(conn, %{"document" => document_params}) do
  user = Guardian.Plug.current_resource(conn)

  with {:ok, document} <- Documents.create_document(document_params, user.id) do
    conn
    |> put_status(:created)
    |> render("show.json", document: document)
  end
end

def upload(conn, params) do
  user = Guardian.Plug.current_resource(conn)

  with {:ok, file_body, _conn} <- Plug.Conn.read_body(conn, length: 100_000_000),
       {:ok, document} <- Documents.handle_file_upload(params, file_body, user.id) do
    conn
    |> put_status(:ok)
    |> render("upload_complete.json", document: document)
  end
end
```

#### ❌ Wrong Pattern - DO NOT DO THIS

```elixir
def create(conn, %{"document" => document_params}) do
  user = Guardian.Plug.current_resource(conn)

  case Documents.create_document(document_params, user.id) do
    {:ok, document} ->
      conn
      |> put_status(:created)
      |> render("show.json", document: document)

    {:error, changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> render("error.json", changeset: changeset)
  end
end
```

#### Parameter Validation

- Rely on Ecto for data casting and validation
- Use parameter validation at the beginning of `with` statements when needed
- Let the fallback controller handle validation errors

#### Success Response Pattern

- Always specify HTTP status codes explicitly with `put_status/2`
- Use appropriate JSON view functions for rendering responses
- Render only the success case - errors are handled by fallback controller

## Testing

- Don't create script files to test functionality, create xunit tests
- xunit test files hould be placed in the test directory at a path that mirrors the functionality they are testing
- We use exmachina (https://hexdocs.pm/ex_machina/readme.html) to setup test data. New tables can bew added to @factory.ex
- run tests with `mix test` and any of the options. No options runs all tests. Options:
  • --failed - runs only tests that failed the last time they ran
  • --force - forces compilation regardless of modification times
  • --include - includes tests that match the filter. This option may be
  given several times to apply different filters, such as --include ci
  --include slow
  • --listen-on-stdin - runs tests, and then listens on stdin. It will
  re-run tests once a newline is received. See the "File system watchers"
  section below
  • --max-cases - sets the maximum number of tests running asynchronously.
  Only tests from different modules run in parallel. Defaults to twice the
  number of cores
  • --max-failures - the suite stops evaluating tests when this number of
  test failures is reached. It runs all tests if omitted
  • --only - runs only tests that match the filter
  • --raise - immediately raises if the test suite fails, instead of
  continuing the execution of other Mix tasks
  • --repeat-until-failure (since v1.17.0) - sets the number of repetitions
  for running the suite until it fails. This is useful for debugging flaky
  tests within the same instance of the Erlang VM. For example,
  --repeat-until-failure 10000 repeats the test suite up to 10000 times until
  the first failure. This can be combined with --max-failures 1 to
  immediately stop if one test fails. However, if there is any leftover
  global state after running the tests, re-running the suite may trigger
  unrelated failures.
  • --seed - seeds the random number generator used to randomize the order
  of tests; --seed 0 disables randomization so the tests in a single file
  will always be ran in the same order they were defined in
  • --stale - runs only tests which reference modules that changed since
  the last time tests were ran with --stale. You can read more about this
  option in the "The --stale option" section below
  • --timeout - sets the timeout for the tests
  • --trace - runs tests with detailed reporting. Automatically sets
  --max-cases to 1. Note that in trace mode test timeouts will be ignored as
  timeout is set to :infinity
  • --warnings-as-errors (since v1.12.0) - treats compilation warnings
  (from loading the test suite) as errors and returns a non-zero exit status
  if the test suite would otherwise pass. Note that failures reported by
  --warnings-as-errors cannot be retried with the --failed flag.
  This option only applies to test files. To treat warnings as errors during
  compilation and during tests, run:
  ```
  - fix any compile warnings seen while testing
  ```

## Production Deployment

### Required Production Secrets

### ECS Task Definition Updates

When adding new secrets, they must be added to `deployment/task_definition.json` in the `secrets` array:

```json
{
  "valueFrom": "{{ PREFIX }}/SECRET_NAME",
  "name": "SECRET_NAME"
}
```

#### Adding S3 Secrets Example

```json
{
  "valueFrom": "{{ PREFIX }}/AWS_ACCESS_KEY_ID",
  "name": "AWS_ACCESS_KEY_ID"
},
{
  "valueFrom": "{{ PREFIX }}/AWS_SECRET_ACCESS_KEY",
  "name": "AWS_SECRET_ACCESS_KEY"
},
{
  "valueFrom": "{{ PREFIX }}/S3_BUCKET_NAME",
  "name": "S3_BUCKET_NAME"
}
```

### Secret Management Guidelines

1. **Never hardcode secrets** in configuration files or code
2. **Always use AWS Systems Manager Parameter Store** for production secrets
3. **Use environment variables** in `config/runtime.exs` to read secrets at runtime
4. **Separate sensitive from non-sensitive** configuration:
   - **Secrets**: Database URLs, API keys, JWT secrets → Parameter Store
   - **Environment Variables**: Regions, non-sensitive URLs → Task definition environment
5. **Update task definition** whenever new secrets are added to the application

## Documentation

- Do not create a separate documentation file unless asked. Prefer documentation in module docs and function docs
- Always use context7 to lookup the documentation for libraries you are using
