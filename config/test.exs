import Config

config :realtime_filter, :temperature,
  max: 38

  # # Config for storage
config :mnesia,
dir: '.mnesia_test/'        # Notice the single quotes
