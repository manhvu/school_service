defmodule Db.RealtimeCheckerJobTest do
  use ExUnit.Case
  doctest Db.RealtimeCheckerJob

  alias Db.Queue
  alias Db.Student
  alias :mnesia, as: Mnesia

  describe "test filter by temperature" do
    test "test alert for high temperature" do
      student = %Student{user_id: "u", school_id: "s", type: :in, temperature: 40, date: DateTime.to_date(DateTime.utc_now())}
      old_size = Mnesia.table_info(:student_alert, :size)
      Queue.add(student)
      Process.sleep(2000)
      new_size = Mnesia.table_info(:student_alert, :size)
      assert new_size == old_size + 1
    end

    test "test no alert for normal temperature" do
      student = %Student{user_id: "u", school_id: "s", type: :in, temperature: 36, date: DateTime.to_date(DateTime.utc_now()) }
      old_size = Mnesia.table_info(:student_alert, :size)
      Queue.add(student)
      Process.sleep(2000)
      new_size = Mnesia.table_info(:student_alert, :size)
      assert new_size == old_size
    end
  end
end
