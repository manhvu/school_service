defmodule Db.Token do
  @moduledoc """
  The module is used to check token (old way) for api.
  """

  use GenServer

  alias ETS.Set

  ## API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__,  [],  name: __MODULE__)
  end

  @doc """
  Gets list of token for user.
  """
  def get_tokens(user_id) do
    r =
      __MODULE__
      |> Set.wrap_existing!()
      |> Set.get(user_id, :not_found)

    case r do
        {:ok, :not_found} -> nil
        {:ok, r}  ->
          inspect(r)
          elem(r, 1)
    end

  end

  @doc """
  Checks a token of a user is existed.
  """
  def existed_token(user_id, token) do
    GenServer.call(__MODULE__, {:existed_token, user_id, token})
  end

  @doc """
  Adds a token for user.
  """
  def add_token(user_id, token) do
    newToken = {token, NaiveDateTime.utc_now() }
    GenServer.cast(__MODULE__, {:add_token, user_id, newToken})
  end

  ## callbacks

  @impl true
  def init(_opts) do
    {:ok, Set.new!(name: __MODULE__)}
  end

  @impl true
  def handle_cast({:add_token, user_id, token}, table) do
    tokens =
      case get_tokens(user_id) do
        nil ->
          [token]
        list ->
          [token|list]
      end

    Set.put(table, {user_id, tokens})
    {:noreply, table}
  end

  @impl true
  def handle_call({:existed_token, user_id, token}, _from, table) do

    result =
      case get_tokens(user_id) do
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
