defmodule Db.QueueTest do
  use ExUnit.Case
  doctest Db.Queue

  alias Db.Queue

  describe "test in/out queue" do
    test "test exactly term for queue" do
      Queue.add(:test)
      assert :test == Queue.get()
    end

    test "test order term for queue" do
      Queue.add(:test1)
      Queue.add(:test2)
      Queue.add(:test3)
      assert :test1 == Queue.get()
      assert :test2 == Queue.get()
      assert :test3 == Queue.get()
    end
  end
end
