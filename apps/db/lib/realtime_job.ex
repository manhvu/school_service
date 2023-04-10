defmodule Db.RealtimeCheckerJob do
  @moduledoc """
  Pushs data from queue to database (disk)
  """

  use GenServer

  require Logger

  alias Db.Student
  alias :mnesia, as: Mnesia

  ## API

  @doc """
  Gets number of record has push to database.
  """
  def add(%Student{} = student) do
    GenServer.cast(__MODULE__, {:add, student})
  end

  def start_link([temperature]) do
    GenServer.start_link(__MODULE__, temperature)
  end

    ## callbacks

  @impl true
  def init(temperature) do
    state = %{data: [], temperature: temperature, counter: 0}

    schedule_work(100)
    {:ok, state}
  end


  @impl true
  def handle_cast({:add, student}, %{temperature: max, data: filtered} = state) do
    filtered =
      if student.temperature > max do
        [student | filtered]
      else
        filtered
      end

    {:noreply, Map.put(state, :data, filtered)}
  end

  @impl true
  def handle_info(:work, %{counter: counter, data: list} = state) do
    state =
    case list do
      [] ->
        schedule_work(3000)
        state
      [student|rest] ->
        r = Student.toTuple(student, :student_alert)

        r2 = Mnesia.transaction(
          fn ->
            Mnesia.write(r)
          end
        )

        Logger.debug("write alert to db, result: #{inspect(r2)}")
        schedule_work(0)
        state = Map.put(state, :counter, counter + 1)
        Map.put(state, :data, rest)
    end

    {:noreply, state}
  end

  @doc """
  Sends a command to worker to process data.
  """
  defp schedule_work(time) do
    # TO-DO: improve this.
    Process.send_after(self(), :work , time)
  end
end
