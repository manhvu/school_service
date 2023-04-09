defmodule FeApiWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  require Logger

  def init(opts), do: opts

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

  def generate_token(user_id) do
    Phoenix.Token.sign(
      FeApiWeb.Endpoint,
      inspect(__MODULE__),
      user_id
    )
  end

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

  def verify_token(token) do
    one_month = 30 * 24 * 60 * 60

    Phoenix.Token.verify(
      FeApiWeb.Endpoint,
      inspect(__MODULE__),
      token,
      max_age: one_month
    )
  end

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
