defmodule Db.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topology = Application.get_env(:libcluster, :topologies)
    hosts = topology[:myapp][:config][:hosts]

    children = [
      # Start a worker by calling: Db.Worker.start_link(arg)
      # {Db.Worker, arg}
      {Db.Token, []},
      {Db.Queue, []},
      {Db.StoreJob, [0]},
      {Cluster.Supervisor, [topology, [name: MyApp.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Db.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FeApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
