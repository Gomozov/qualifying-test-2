use Mix.Config
  import_config "test.secret.exs"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :extop, Extop.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :extop, sql_sandbox: true

# Configure your database
config :extop, Extop.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "extop_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :exvcr, [
  filter_sensitive_data: [
    [pattern: "token [0-9a-z]+", placeholder: "*****"]
  ],
  filter_url_params: false,
  response_headers_blacklist: ["Set-Cookie", "X-Request-Id"]
]
