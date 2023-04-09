
defmodule FeApiWeb.Student do
  alias FeApiWeb.Student

  @derive Nestru.Decoder
  defstruct [:uuid, :timestamp, :userId, :schoolId, :temperature, :type]

  def toTuple(%Student{} = student, firstElem) when is_atom(firstElem) do
    {firstElem, student.uuid, student.userId, student.schoolId, student.type, student.temperature, student.timestamp}
  end
end
