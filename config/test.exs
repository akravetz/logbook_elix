import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :logbook_elix, LogbookElix.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "logbook_elix_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :logbook_elix, LogbookElixWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "kxYt/UmWk2PTB38TBdS4JktIZWMsQAjakvi7YV7tnNwNYNYN1oShDqlg6TD0iUqi",
  server: false

# In test we don't send emails
config :logbook_elix, LogbookElix.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Guardian configuration for testing
config :logbook_elix, LogbookElix.Auth.Guardian,
  secret_key: "test-secret-key-change-in-production",
  ttl: {3, :hours}

# DeepGram API configuration for testing
config :logbook_elix, :deepgram_api_key, "test-deepgram-api-key"
