# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :fe_api, FeApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FeApiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FeApi.PubSub,
  live_view: [signing_salt: "8+4oL3mA"],
  adapter: Bandit.PhoenixAdapter


# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# # Config for storage
config :mnesia,
  dir: '.mnesia/'        # Notice the single quotes

config :realtime_filter, :temperature,
  max: 38

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
