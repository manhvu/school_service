defmodule FeApiWeb.Auth do
  @moduledoc """
  Uses for authenticate for REST API. Current version just support token generate from app.
  Module is a plug for phoenix framework.
  """

  import Plug.Conn
  import Phoenix.Controller

  require Logger

  @spec init(any) :: any
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
    |> get_token()
    |> verify_token()
    |> case do
      {:ok, userId} ->
        Logger.debug("verify token sucess for #{userId}")
        assign(conn, :currentUser, userId)
      _unauthorized ->
        # skip for test & dev environment.
        if Application.get_env(:fe_api, :test_env)[:disable_auth] do
          Logger.debug("ignore authenticate, disable from config")
          assign(conn, :currentUser, "test_user")
        else
          assign(conn, :currentUser, nil)
        end
    end
  end

  @doc """
  Generates token for APIs of a user.
  """
  @spec generate_token(any) :: nonempty_binary
  def generate_token(user_id) do
    Phoenix.Token.sign(
      FeApiWeb.Endpoint,
      inspect(__MODULE__),
      user_id
    )
  end

  @doc """
  check if user is valid
  """
  @spec authenticate_api_user(atom | %{:assigns => map, optional(any) => any}, any) ::
          atom | %{:assigns => map, optional(any) => any}
  def authenticate_api_user(conn, _opts) do
    if Map.get(conn.assigns, :currentUser) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(FeApiWeb.ErrorView)
      |> render(:"401")
      |> halt()
    end
  end

  @doc """
  verifies token, current valid time is one month.
  """
  @spec verify_token(nil | binary) :: {:error, :expired | :invalid | :missing} | {:ok, any}
  def verify_token(token) do
    one_month = 30 * 24 * 60 * 60

    Phoenix.Token.verify(
      FeApiWeb.Endpoint,
      inspect(__MODULE__),
      token,
      max_age: one_month
    )
  end

  @doc """
  extracts token from header.
  """
  @spec get_token(Plug.Conn.t()) :: nil | binary
  def get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        Logger.debug("token is included in header")
        token
      _ ->
        Logger.debug("token is missed in header")
        nil
    end
  end
end
