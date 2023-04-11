defmodule Db.StoreJobTest do
  use ExUnit.Case
  doctest Db.StoreJob

  alias Db.Queue
  alias Db.Student
  alias :mnesia, as: Mnesia
  import Db.Storage

  describe "test store data to mnesia db" do
    test "store 1 item to db" do
      student = %Student{user_id: "u", school_id: "s", type: :in, temperature: 40, date: DateTime.to_date(DateTime.utc_now())}
      table = gen_table_name(student)
      old_size = Mnesia.table_info(table, :size)
      Queue.add(student)
      Process.sleep(2000) # wait for clear queue and data is pushed to db.
      new_size = Mnesia.table_info(table, :size)
      assert new_size == old_size + 1
    end
  end
end
