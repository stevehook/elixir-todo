defmodule Todo.SessionControllerTest do
  use Todo.ConnCase
  alias Todo.User
  alias Todo.Repo

  def create_user do
    { :ok, user } = %User{name: "Bob Roberts", email: "bob@example.com", password: "secret"}
    |> Repo.insert
    user
  end

  def credentials_as_json(email, password) do
    %{ "user" => %{"email" => email, "password" => password} }
    |> Poison.encode!()
  end

  @tag :pending
  test "POST /api/sessions creates a new session given valid credentials" do
    user = create_user
    params = credentials_as_json("bob@example.com", "secret")

    conn = conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)

    assert json_response(conn, 201)
  end

  test "POST /api/sessions does NOT create a new session given invalid password" do
    user = create_user
    params = credentials_as_json("bob@example.com", "wrong")

    conn = conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)

    assert json_response(conn, 422)
  end

  test "POST /api/sessions does NOT create a new session given invalid email" do
    user = create_user
    params = credentials_as_json("alice@example.com", "secret")

    conn = conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)

    assert json_response(conn, 422)
  end

  test "DELETE /api/sessions deletes an existing session" do
    conn = conn
    |> put_req_header("content-type", "application/json")
    |> delete("/api/sessions")

    assert json_response(conn, 200)
  end

  test "GET /api/sessions fetches an existing session" do
    conn = conn
    |> put_req_header("content-type", "application/json")
    |> get("/api/sessions")

    assert json_response(conn, 200)
  end

  test "GET /api/sessions fails with 422 when there is no session" do
    conn = conn
    |> put_req_header("content-type", "application/json")
    |> get("/api/sessions")

    assert json_response(conn, 422)
  end
end
