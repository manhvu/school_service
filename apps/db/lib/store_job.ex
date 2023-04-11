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
  alias Db.Storage
  import Db.Storage
  ## API

  @doc """
  Gets number of record has push to database.
  """
  def get_counter() do

  end

  def start_link([counter]) do
    Logger.info("start store data to db worker")
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
        write_to_db(student)
        schedule_work(0)
        counter + 1
    end

    {:noreply, counter}
  end

  defp schedule_work(time) do
    # TO-DO: improve this.
    Process.send_after(self(), :work , time)
  end

  defp write_to_db(%Student{} = student) do
    {_, table} = ensure_exist_table(student)
    add_record(table, student)
    Logger.debug("added #{inspect student} to db.")
end

end
