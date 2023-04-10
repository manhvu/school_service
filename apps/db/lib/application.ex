defmodule Db.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Db.Token, []},
      {Db.Queue, []},
      {Db.StoreJob, [0]}
    ]

    children =
      case Application.get_env(:realtime_filter, :temperature)[:max] do
        # default is one worker.
        nil ->
          children
        n when is_integer(n) and n > 0 ->
          # enable realtime filter
          [{Db.RealtimeCheckerJob, [n]} | children]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Db.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
