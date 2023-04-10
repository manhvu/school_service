defmodule SimuTraffic.Worker do
  @moduledoc """
  Simulates traffic to test frontend api.
  """

  alias SimuTraffic.Worker

  require Logger

  @derive Nestru.Encoder
  defstruct [:timestamp, :userId, :schoolId, :temperature, :type]

  def start_link(arg) do
    pid = spawn_link(__MODULE__, :init, [arg])
    {:ok, pid}
  end

  def init({id, counter, url}) do
    Logger.debug "start worker(#{id}) with counter = #{counter}, url = #{url}"
    Process.put(:start_time, get_timestamp())
    loop_request(id, counter, url, %{success: 0, failed: 0, error: 0})
  end


  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient,
      shutdown: :brutal_kill
    }
  end

  @doc """
  loop function, generate fake data and send to frontend api.
  in case counter < 0 -> infinity request will send to server.
  """
  def loop_request(id, 0, _url, stat) do
    stop_time = get_timestamp()
    start_time = Process.get(:start_time)

    %{success: s} = stat
    %{failed: f} = stat
    %{error: e} = stat

    Logger.info "Simu Traffic, worker(#{id}) DONE!, time: #{stop_time - start_time}s, success: #{s}, failed: #{f}, error: #{e}"
  end
  def loop_request(id, n, url, %{} = stat) do
    student = %Worker{
      timestamp: get_timestamp(),
      userId: "user_" <> Integer.to_string(Enum.random(1..10000)),
      schoolId: "school_" <> Integer.to_string(Enum.random(1..1500)) ,
      temperature: Enum.random(30..42), # temperature at Celius
      type: get_random_type()
    }
    {:ok, map} =  Nestru.encode_to_map(student)
    body = Jason.encode!(map)
    Logger.debug("json: #{body}")

    stat =
      case HTTPoison.post(url, body, [{"content-type", "application/json"}]) do
        {:ok, %{status_code: 201, body: _body2}} ->
          Map.update!(stat, :success, &(&1 + 1))
        {:ok, %{status_code: code}} ->
          Logger.debug "failed to post data return code: #{code}"
          Map.update!(stat, :failed, &(&1 + 1))
        {:error, %{reason: reason}} ->
          Logger.debug "error to post data return code: #{inspect  reason}"
          Map.update!(stat, :error, &(&1 + 1))
      end

      if n > 0 do
        loop_request(id, n - 1, url, stat)
      else
        loop_request(id, n, url, stat)
      end
  end

  @doc """
  Gets timestamp from os.
  """
  def get_timestamp do
    :os.system_time(:seconds)
  end

  @doc """
  Randoms checkin/checkout action.
  """
  def get_random_type do
    case Enum.random(1..2) do
      1 ->
        :in
      _ ->
        :out
    end
  end
end
