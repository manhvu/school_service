
defmodule FeApiWeb.Student do
  @moduledoc """
  define student check in/out information.
  """

  alias FeApiWeb.Student

  @derive Nestru.Decoder
  defstruct [:uuid, :timestamp, :userId, :schoolId, :temperature, :type]

  @doc """
  convert struct to a tuple (a record in Erlang) to write to mnesia.
  """
  def toTuple(%Student{} = student, firstElem) when is_atom(firstElem) do
    {firstElem, student.uuid, student.userId, student.schoolId, student.type, student.temperature, student.timestamp}
  end
end
