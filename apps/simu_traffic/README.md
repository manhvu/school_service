# Simulator Traffic (simu_traffic)

Use for workload test FeApi.

## Achitecture

The app generates request and send to FeApi app. The app can use number of client to simulate concurrent request.

## Dev Guide

The app require config before start. You can check it in config file.

For run test:
```bash
cd ./apps/simu_traffic
mix test
```

For run Elixir:
```bash
cd ./app/simu_traffic
iex -S mix phx.server
```

Then run command in Elixir shell:
```bash
Application.ensure_all_started(:simu_traffic)
```