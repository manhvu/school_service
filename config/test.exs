import Config

config :realtime_filter, :temperature,
  max: 38

  # # Config for storage
config :mnesia,
dir: '.mnesia_test/'        # Notice the single quotes


config :fe_api, FeApiWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 8080],
  check_origin: false,
  debug_errors: true,
  secret_key_base: "Fbtyydbohz7kL9tazhopcUsnVpJATZ1eWuTLStd3SuHCvtSR1CNmadXdsFgWMsgK"

  config :fe_api, :test_env,
    disable_auth: false # disable to test token


config :logger, :console,
  level: :debug,
  format: "$time[$level] $message $metadata\n"
