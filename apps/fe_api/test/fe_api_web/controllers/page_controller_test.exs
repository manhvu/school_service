defmodule FeApiWeb.StudentControllerTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias Db.Student
  alias FeApiWeb.Auth

  describe "test fe api" do
    test "test verify token & POST student log to fe api" do
      student_json =
        %Student{user_id: "u", school_id: "s", type: "in", temperature: 37, timestamp: 1649541125}
        |> Map.delete(:__struct__)

      conn = conn(:post, "/api/student", student_json) |> put_req_header("authorization", "Bearer " <> Auth.generate_token("test_user")) |> FeApiWeb.Endpoint.call([])

      assert conn.status == 201
    end

    test "test verify token fail for fe api" do
      student_json =
        %Student{user_id: "u", school_id: "s", type: "in", temperature: 37, timestamp: 1649541125}
        |> Map.delete(:__struct__)

      conn = conn(:post, "/api/student", student_json) |> put_req_header("authorization", "Bearer abcde") |> FeApiWeb.Endpoint.call([])

      assert conn.status == 401
    end
  end
end
