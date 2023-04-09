defmodule SimuTraffic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    test_info = Application.get_env(:simu_traffic, :test_info)
    number_of_worker = test_info[:number_worker]

    children = [
      {SimuTraffic.Worker, []},
      {DynamicSupervisor, strategy: :one_for_one, name: SimuTraffic.DynamicSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimuTraffic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
