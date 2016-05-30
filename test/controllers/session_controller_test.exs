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

  test "DELETE /api/session deletes an existing session" do
    conn = conn
    |> put_req_header("content-type", "application/json")
    |> delete("/api/session")

    assert json_response(conn, 200)
  end

  test "GET /api/session fetches an existing session" do
    user = create_user

    # First login
    params = credentials_as_json("bob@example.com", "secret")
    login_conn = Phoenix.ConnTest.conn()
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)
    jwt = Guardian.Plug.current_token(login_conn)

    conn = conn
    |> put_req_header("authorization", jwt)
    |> put_req_header("content-type", "application/json")
    |> get("/api/session")

    # Doesn't work because dates are not just converted to strings in JSON serializer
    # expected = user
    #   |> Map.from_struct
    #   |> Map.drop([:__meta__, :__struct__])
    #   |> Enum.reduce(%{}, fn ({key, val}, acc) -> Map.put(acc, Atom.to_string(key), Kernel.to_string(val)) end)

    expected = user
      |> Poison.encode!
      |> Poison.decode!

    assert json_response(conn, 200) == expected
  end

  test "GET /api/session fails with 422 when the JWT auth header is missing" do
    create_user

    # First login
    params = credentials_as_json("bob@example.com", "secret")
    login_conn = Phoenix.ConnTest.conn()
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)

    conn = conn
    |> put_req_header("authorization", "this is not the token you are looking for")
    |> put_req_header("content-type", "application/json")
    |> get("/api/session")

    assert json_response(conn, 422)
  end

  test "GET /api/session fails with 422 when there is no session" do
    conn = conn
    |> put_req_header("content-type", "application/json")
    |> get("/api/session")

    assert json_response(conn, 422)
  end
end
