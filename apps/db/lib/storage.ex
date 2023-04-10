defmodule Db.Storage do
  @moduledoc """
  Define the schema, table and init mnesia database.
  """

  alias FeApiWeb.Student
  alias :mnesia, as: Mnesia

  require Record
  require Logger

  Record.defrecord(:studentLog, uuid: nil, userId: nil, schoolId: nil,  timestamp: 0, type: :in, temperature: 0)

  @doc """
  Simple check exist database or create a new database.
  """
  def initDb() do
    Logger.info("start init database...")
    result =
      case Mnesia.create_schema([node()]) do
        :ok ->
          :ok
        {:error, {_, {:already_exists, _}}} ->
          :existed
        r ->
          Logger.error("cannot create schema, result: #{inspect r}")
          raise "cannot create db"
      end

    case Mnesia.start() do
      :ok ->
        :ok
      nil ->
        :ok = Mnesia.wait_for_tables([:studentLog], 15000)
    end

    if result != :existed do
      case  Mnesia.create_table(:studentLog,
        [
          record_name: :studentLog,
          disc_copies: [node()],
          attributes: studentLog() |> studentLog() |> Keyword.keys()
        ]) do
        {:atomic, :ok} ->
          :ok
        {:aborted, {:already_exists, _}} ->
          :ok
        r ->
          Logger.error("cannot create schema, result: #{inspect r}")
          raise "failed to create table"
      end
    else
      :ok
    end

    Logger.info("init database done.")
  end

  @doc """
  Gets number of record stored in database.
  """
  def get_counter() do
    Mnesia.table_info(:studentLog, :size)
  end
end
