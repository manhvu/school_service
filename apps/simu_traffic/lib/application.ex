defmodule SimuTraffic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do

    # generates worker base on config.
    children = [{DynamicSupervisor, strategy: :one_for_one, name: SimuTraffic.DynamicSupervisor} | gen_worker()]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimuTraffic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Generate worker list based on config.
  """
  @spec gen_worker :: list
  def gen_worker() do
    number_of_worker =
      case Application.get_env(:simu_traffic, :test_info)[:worker] do
        # default is one worker.
        nil ->
          1
        n when is_integer(n) and n > 0 ->
          n
      end

    counter =
      case Application.get_env(:simu_traffic, :test_info)[:counter] do
        nil ->
          raise "missed counter for simu traffic"
        n when is_integer(n)->
            n
      end
    url =
      case Application.get_env(:simu_traffic, :test_info)[:url] do
        nil ->
          raise "missed url for simu traffic"
        s when is_binary(s)->
            s
      end

    counter_per_worker =
      case counter do
        n when n < 0 ->
          n
        _ ->
          div(counter, number_of_worker)
      end

    Logger.info("number of worker: #{number_of_worker}, counter per worker: #{counter_per_worker}, url: #{url}")
    gen_worker([], number_of_worker, counter_per_worker, url)
  end

  def gen_worker(result, 0, _counter, _url) do
    result
  end
  def gen_worker(result, number_of_worker, counter, url) when number_of_worker > 0 do
    gen_worker([Supervisor.child_spec({SimuTraffic.Worker, {number_of_worker, counter, url}}, id: "worker_#{number_of_worker}") | result], number_of_worker - 1, counter, url)
  end
end
