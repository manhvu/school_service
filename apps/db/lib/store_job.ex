defmodule Db.StoreJob do
  use GenServer

  alias Db.Queue
  alias FeApiWeb.Student
  alias :mnesia, as: Mnesia

  ## API
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
        schedule_work(1000)
        counter
      student ->
        r = Student.toTuple(student, :studentLog)

        r2 = Mnesia.transaction(
          fn ->
            Mnesia.write(r)
          end
        )

        IO.inspect(r2)
        schedule_work(0)
        counter + 1
    end

    {:noreply, counter}
  end

  defp schedule_work(time) do
    # After 5 seconds(5 * 1000 in milliseconds) the desired task will take place.
    Process.send_after(self(), :work , time)
  end
end
