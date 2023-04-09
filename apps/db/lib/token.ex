defmodule Db.Token do
  use GenServer

  alias ETS.Set

  ## API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__,  [],  name: __MODULE__)
  end

  def get_tokens(userId) do
    r =
      __MODULE__
      |> Set.wrap_existing!()
      |> Set.get(userId, :not_found)

    case r do
        {:ok, :not_found} -> nil
        {:ok, r}  ->
          inspect(r)
          elem(r, 1)
    end

  end

  def existed_token(userId, token) do
    GenServer.call(__MODULE__, {:existed_token, userId, token})
  end

  def add_token(userId, token) do
    newToken = {token, NaiveDateTime.utc_now() }
    GenServer.cast(__MODULE__, {:add_token, userId, newToken})
  end

  ## callbacks

  @impl true
  def init(_opts) do
    {:ok, Set.new!(name: __MODULE__)}
  end

  @impl true
  def handle_cast({:add_token, userId, token}, table) do
    tokens =
      case get_tokens(userId) do
        nil ->
          [token]
        list ->
          [token|list]
      end

    Set.put(table, {userId, tokens})
    {:noreply, table}
  end

  @impl true
  def handle_call({:existed_token, userId, token}, _from, table) do

    result =
      case get_tokens(userId) do
         nil ->
           false
        list when is_list(list) ->
          check_token(token, list)
        _ ->
          false
      end

    {:reply, result, table}
  end

  defp check_token(token, [h|rest]) do
    case h do
      {^token, t} ->
        true
      _ ->
        check_token(token, rest)
    end
  end
  defp check_token(_, []) do
    false
  end
end
