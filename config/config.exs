# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :compose,
  ecto_repos: [Compose.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :compose, ComposeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ComposeWeb.ErrorHTML, json: ComposeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Compose.PubSub,
  live_view: [signing_salt: "vWNn7+4g"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :compose, Compose.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  compose: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  compose: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :compose, Compose.LLM,
  default_backend: Compose.LLM.Backend.Ollama,
  backends: [
    ollama: [
      base_url: "http://localhost:11434",
      model: "llama3:latest",
      stream: false,
      format: "json"
    ],
    perplexity: [
      base_url: "https://api.perplexity.ai",
      model: "mixtral-8x7b-instruct",
      stream: false,
      # JSON format not yet supported
      # format: %{"type" => "json_object"},
      api_key: System.get_env("PERPLEXITY_API_KEY")
    ],
    openai: [
      base_url: "https://api.openai.com",
      model: "gpt-4o",
      stream: false,
      format: %{"type" => "json_object"},
      api_key: System.get_env("OPENAI_API_KEY")
    ],
    mistral: [
      base_url: "https://api.mistral.ai",
      model: "mistral-small-latest",
      stream: false,
      format: %{"type" => "json_object"},
      api_key: System.get_env("MISTRAL_API_KEY")
    ]
  ]

config :finch, :opts,
  receive_timeout: 1_000_000 * 60 * 60,
  pool_timeout: 1_000_000 * 60 * 60,
  request_timeout: 1_000_000 * 60 * 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
