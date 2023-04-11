defmodule Db.StorageTest do
  use ExUnit.Case
  doctest Db.Storage

  alias Db.Student
  import Db.Storage

  describe "test create mnesia table" do
    test "test generate table name" do
      student = %Student{user_id: "u", school_id: "s", type: :in, temperature: 37, date: ~D[2023-01-30]}
      assert :"student_2023-01-30" == gen_table_name(student)
      dt = DateTime.utc_now()
      str = "student_#{Date.to_string(DateTime.to_date(dt))}"
      assert String.to_atom(str) == gen_table_name(dt)
    end

  end
end
