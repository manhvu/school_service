
defmodule Db.Student do
  @moduledoc """
  define student check in/out information.
  """

  alias Db.Student

  @derive Nestru.Decoder
  defstruct [:uuid, :timestamp, :user_id, :school_id, :temperature, :type]

  @doc """
  convert struct to a tuple (a record in Erlang) to write to mnesia.
  """
  def toTuple(%Student{} = student, firstElem) when is_atom(firstElem) do
    {firstElem, student.uuid, student.user_id, student.school_id, student.type, student.temperature, student.timestamp}
  end
end
