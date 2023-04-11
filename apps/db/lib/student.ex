
defmodule Db.Student do
  @moduledoc """
  define student check in/out information.
  """

  require Logger
  alias Db.Student

  @derive Nestru.Decoder
  defstruct [:uuid, :user_id, :school_id, :date, :timestamp, :temperature, :type]

  @doc """
  convert struct to a tuple (a record in Erlang) to write to mnesia.
  """
  def to_tuple(%Student{} = student, firstElem) when is_atom(firstElem) do
    {firstElem, student.user_id, student.school_id, student.type, student.temperature, student.date}
  end

  def valid_data(%Student{} = student) do
    cond do
      student.school_id == "" || student.school_id == nil ->
        Logger.info("school_id is invalid, #{inspect student}")
        false
      student.user_id == "" || student.user_id == nil ->
        Logger.info("user_id is invalid, #{inspect student}")
        false
      Date.compare(student.date, NaiveDateTime.to_date(NaiveDateTime.utc_now())) == :gt ->
        Logger.debug("current time: #{NaiveDateTime.utc_now()}")
        Logger.info("timestamp(date) is invalid, #{inspect student}")
        false
      true ->
        true
    end
  end
end
