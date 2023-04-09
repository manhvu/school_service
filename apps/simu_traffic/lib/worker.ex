defmodule SimuTraffic.Worker do
  alias SimuTraffic.Worker

  require Logger

  @derive Nestru.Encoder
  defstruct [:timestamp, :userId, :schoolId, :temperature, :type]

  def start_link(_arg) do
    pid = spawn_link(__MODULE__, :init, [:ok])
    {:ok, pid}
  end

  def init(_arg) do
    counter =
      case Application.get_env(:simu_traffic, :test_env)[:counter] do
        nil ->
          raise "missed counter for simu traffic"
        n when is_integer(n)->
            n
      end
    url =
      case Application.get_env(:simu_traffic, :test_env)[:url] do
        nil ->
          raise "missed url for simu traffic"
        s when is_binary(s)->
            s
      end

    Logger.debug "start worker with counter = #{counter}, url = #{url}"
    loop_request(counter, url, %{success: 0, failed: 0, error: 0})
  end


  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  # if loop couter < 0 that min simu traffic will run non stop!
  def loop_request(0, _url, stat) do
    %{success: s} = stat
    %{failed: f} = stat
    %{error: e} = stat

    Logger.debug "Simu Traffic DONE!, success: #{s}, failed: #{f}, error: #{e}"
  end
  def loop_request(n, url, %{} = stat) do
    student = %Worker{
      timestamp: get_timestamp(),
      userId: "user_" <> Integer.to_string(Enum.random(1..10000)),
      schoolId: "school_" <> Integer.to_string(Enum.random(1..1500)) ,
      temperature: Enum.random(30..42) # temperature at Celius
    }
    {:ok, map} =  Nestru.encode_to_map(student)
    body = Jason.encode!(map)
    stat =
      case HTTPoison.post(url, body) do
        {:ok, %{status_code: 201, body: body2}} ->
          Map.update!(stat, :success, &(&1 + 1))
        {:ok, %{status_code: code}} ->
          Logger.debug "failed to post data return code: #{code}"
          Map.update!(stat, :failed, &(&1 + 1))
        {:error, %{reason: reason}} ->
          Logger.debug "error to post data return code: #{inspect  reason}"
          Map.update!(stat, :error, &(&1 + 1))
      end

      if n > 0 do
        loop_request(n - 1, url, stat)
      else
        loop_request(n, url, stat)
      end
  end

  def get_timestamp do
    :os.system_time(:seconds)
  end
end
