defmodule Db.Queue do
  @moduledoc """
  This module is a queue. Receives data and storage in memory then other job can consume later.
  App has one global queue.
  """

  use GenServer
  require Logger

  ## API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__,  [],  name: __MODULE__)
  end

  @doc """
  receives data then store in queue.
  """
  def add(data) do
    GenServer.cast(__MODULE__, {:in, data})
  end

  @doc """
  gets data from queue
  """
  def get() do
    GenServer.call(__MODULE__, {:out})
  end

  ## callbacks

  @impl true
  def init(_opts) do
    Logger.debug("started queue")
    {:ok, :queue.new()}
  end

  @impl true
  def handle_cast({:in, data}, q) do
    {:noreply, :queue.in(data, q)}
  end

  @impl true
  def handle_call({:out}, _from, q) do
    {result, q2} =
      case :queue.out(q) do
        {{:value, data}, q1} ->
          {data, q1}
        {:empty, q1} ->
          {nil, q1}
      end

    {:reply, result, q2}
  end
end
