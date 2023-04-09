defmodule FeApiWeb.StudentController do
  use FeApiWeb, :controller

  require Logger

  alias FeApiWeb.Student
  alias Db.Queue

  action_fallback FeApiWeb.FallbackController
  plug :authenticate_api_user when action in [:create]

  def create(conn, _params) do
    Logger.debug("print body\n #{inspect conn.body_params}")
    map = Map.put(conn.body_params, "uuid", UUID.uuid1())

    {:ok, student} = Nestru.decode_from_map(map, Student)
    Logger.debug("print struct\n #{inspect student}")

   Queue.add(student)

   conn
   |> put_status(:created)
   |> render("result.json", result: "added")
  end

  def index(conn, _params) do
    conn |> text("ok")
  end

end
