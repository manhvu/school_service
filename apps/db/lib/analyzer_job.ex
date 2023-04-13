defmodule Db.Analyzer do
  @moduledoc """
  Aggregrate & analysis data from student's log.
  """

  use GenServer

  require Logger

  alias :mnesia, as: Mnesia
  import Db.Storage

  ## API

  @doc """
  Add job to queue
  """
  def add(job) when is_map(job) do
    GenServer.cast(__MODULE__, {:add, job})
  end

  @doc """
  For start worker in supervisor.
  """
  def start_link([]) do
    Logger.info("start analyzer.")
    GenServer.start_link(__MODULE__,  [],  name: __MODULE__)
  end

    ## callbacks

  @impl true
  def init(_) do
    Logger.debug("started analyzer")
    schedule_work(100)
    {:ok, %{jobs: []}}
  end

  @impl true
  def handle_cast({:add, job}, %{jobs: jobs} = state) do
    {:noreply, Map.put(state, :jobs,  [job|jobs])}
  end

  @impl true
  def handle_info(:work, %{jobs: jobs} = state) do
    state =
    case jobs do
      [] ->
        schedule_work(1000)
        state
      [job|rest] ->
        Logger.debug("start new job: #{inspect job}")
        do_job(job)
        schedule_work(0)
        Map.put(state, :jobs, rest)
    end

    {:noreply, state}
  end

  defp schedule_work(time) do
    # TO-DO: improve this.
    Process.send_after(self(), :work , time)
  end

  def do_job(%{date: date, high_tem: high_tem} = job) do
    table = gen_table_name(date)
    true = table_exists(table)
    result_table = gen_result_table_name(date)
    ensure_exist_table(result_table)
    r =
    Mnesia.transaction(fn ->
      Mnesia.foldl(fn({_, user_id, school_id, type, tem, date} = record, _) ->
        Logger.debug("processing date: #{inspect date}, user_id: #{user_id}, school_id: #{school_id}")
        # mark fever if temperature is high.
        tem2 =
          if tem >= high_tem do
            {:fever, tem}
          else
            {:normal, tem}
          end
        type2 =
          case type do
            "in" -> "out"
            "out" -> "in"
          end

        # check type is full (check-in & check-out) or not.
        type3 =
          case Mnesia.match_object({table, user_id, school_id, type2, :_, :_}) do
            [_] ->
              {"in", "out"}
            _ ->
              {type}
          end

        # save result to other table.
        :ok = Mnesia.write({result_table, user_id, school_id, type3, tem2, date})
      end, :ok, table)
    end)
    Logger.debug("result for job: #{inspect job}, #{inspect r}")
  end
end
