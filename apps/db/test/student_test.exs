defmodule Db.StudentTest do
  use ExUnit.Case
  doctest Db.Student

  alias Db.Student

  describe "test %Student{} struct" do
    test "test convert to tuple" do
      student = %Student{user_id: "u", school_id: "s", type: :in, temperature: 37, date: ~D[2023-04-10]}
      assert match?({:test, "u", "s", :in, 37, ~D[2023-04-10]}, Student.to_tuple(student, :test))
    end

    test "test valid data" do
      student = %Student{user_id: "u", school_id: "s", type: :in, temperature: 37, date: ~D[2023-04-10]}
      assert true == Student.valid_data(student)
    end

    test "test invalid data, field user_id" do
      student = %Student{user_id: "", school_id: "s", type: :in, temperature: 37, date: ~D[2023-04-10]}
      assert false == Student.valid_data(student)
    end

    test "test invalid data, field school_id" do
      student = %Student{user_id: "u", type: :in, temperature: 37, date: ~D[2023-04-10]}
      assert false == Student.valid_data(student)
    end

    test "test invalid data, field timestamp" do
      student = %Student{user_id: "u", type: :in, temperature: 37, date: ~D[2050-01-01]}
      assert false == Student.valid_data(student)
    end
  end
end
