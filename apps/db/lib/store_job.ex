defmodule Db.StoreJob do
  @moduledoc """
  Pushs data from queue to database (disk)
  """

  use GenServer

  require Logger

  alias Db.Queue
  alias :mnesia, as: Mnesia
  alias Db.RealtimeCheckerJob, as: Filter
  alias Db.Student

  ## API

  @doc """
  Gets number of record has push to database.
  """
  def get_counter() do

  end

  def start_link([counter]) do
    GenServer.start_link(__MODULE__, counter)
  end

    ## callbacks

  @impl true
  def init(counter) do
    alias Db.Storage
    :ok = Storage.initDb()

    schedule_work(100)
    {:ok, counter}
  end

  @impl true
  def handle_info(:work, counter) do
    counter =
    case Queue.get() do
      nil ->
        # sleep more if queue doesn't have data.
        schedule_work(1000)
        counter
      student ->
        Filter.add(student)
        r = Mnesia.transaction(
          fn ->
            Mnesia.write(Student.toTuple(student, :student_log))
          end
        )

        Logger.debug("write data to db, result: #{inspect(r)}")
        schedule_work(0)
        counter + 1
    end

    {:noreply, counter}
  end

  @doc """
  Sends a command to worker to process data.
  """
  defp schedule_work(time) do
    # TO-DO: improve this.
    Process.send_after(self(), :work , time)
  end
end
