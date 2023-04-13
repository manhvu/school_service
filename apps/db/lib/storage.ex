defmodule Db.Storage do
  @moduledoc """
  Define the schema, table and init mnesia database.
  """

  alias :mnesia, as: Mnesia
  alias Db.Student

  require Record
  require Logger

  @attr [:user_id, :school_id, :type, :temperature, :date]

  @doc """
  Simple check exist database or create a new database.
  """
  def initDb() do
    Logger.info("start init database...")
    result =
      case Mnesia.create_schema([node()]) do
        :ok ->
          Logger.info("mnesia create schema done.")
          :ok
        {:error, {_, {:already_exists, _}}} ->
          Logger.info("mnesia create schema failed, existed.")
          :existed
        r ->
          Logger.error("cannot create schema, result: #{inspect r}")
          raise "cannot create db"
      end

    case Mnesia.start() do
      :ok ->
        Logger.info("mnesia start done.")
        :ok
      nil ->
        Logger.info("mnesia start return failed, waiting load table...")
        :ok = Mnesia.wait_for_tables([gen_table_name(DateTime.now!("Etc/UTC"))], 15000)
    end

    if result != :existed do
      # Logger.info("create table student_log")
      # :ok = create_disk_table(:student_log, @attr, :bag)
      Logger.info("create table student_alert")
      :ok = create_disk_table(:student_alert, @attr, :bag)
    else
      Logger.info("skip create table, existed")
    end

    Logger.info("init database done.")
    :ok
  end

  def create_disk_table(name, attr, type) when is_atom(name) do
      case  Mnesia.create_table(name,
        [
          record_name: name,
          disc_only_copies: [node()],
          attributes: attr,
          type: type
        ]) do
        {:atomic, :ok} ->
          :ok
        {:aborted, {:already_exists, _}} ->
          :ok
        r ->
          Logger.error("cannot create table(#{inspect name}), result: #{inspect r}")
          r
      end
  end

  @doc """
  Gets number of record stored in database.
  """
  def get_counter(table) when is_atom(table) do
    history = Mnesia.table_info(table, :size)
    alert = Mnesia.table_info(:student_alert, :size)
    {alert, history}
  end

  def add_record(table, %Student{} = student) when is_atom(table) do
    {:atomic, :ok} = Mnesia.transaction(
      fn ->
        Mnesia.write(Student.to_tuple(student, table))
      end
    )
  end

  def gen_table_name(%Student{} = student) do
    str_name ="student_#{ Date.to_string(student.date)}"
    String.to_atom(str_name)
  end

  def gen_table_name(%DateTime{} = date_time) do
    str_name ="student_#{ Date.to_string(DateTime.to_date(date_time))}"
    String.to_atom(str_name)
  end

  def gen_table_name(%Date{} = date) do
    str_name ="student_#{ Date.to_string(date)}"
    String.to_atom(str_name)
  end

  def gen_result_table_name(%Student{} = student) do
    str_name ="result_#{ Date.to_string(student.date)}"
    String.to_atom(str_name)
  end

  def gen_result_table_name(%DateTime{} = date_time) do
    str_name ="result_#{ Date.to_string(DateTime.to_date(date_time))}"
    String.to_atom(str_name)
  end

  def gen_result_table_name(%Date{} = date) do
    str_name ="result_#{ Date.to_string(date)}"
    String.to_atom(str_name)
  end

  def ensure_exist_table(%Student{} = student) do
    table_name = gen_table_name(student)
    ensure_exist_table(table_name)
  end
  def ensure_exist_table(table_name) when is_atom(table_name) do
    Logger.debug("table name for check, #{table_name}")
    case Process.get(:last_table) do
      nil ->
        Logger.debug("#{inspect table_name} doesn't exist, create new one")
        :ok = create_disk_table(table_name, @attr, :bag)
        Process.put(:last_table, table_name)
        {nil, table_name}
      ^table_name ->
        Logger.debug("#{inspect table_name} exists, skip create new one")
        {table_name, table_name}
      old_table ->
        Logger.debug("#{inspect table_name} doens't exist, create new table to replace old table")
        :ok = create_disk_table(table_name, @attr, :bag)
        Process.put(:last_table, table_name)
        {old_table, table_name}
    end
  end

  def table_exists(table) when is_atom(table) do
    list_table = Mnesia.system_info(:tables)
    Enum.member?(list_table, table)
  end
end
