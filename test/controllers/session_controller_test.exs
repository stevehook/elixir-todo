defmodule Todo.SessionControllerTest do
  use Todo.ConnCase
  alias Todo.User
  alias Todo.Repo

  test "POST /api/sessions creates a new session given valid credentials" do
    user = create_user
    params = credentials_as_json("bob@example.com", "secret")

    expected = user
    |> Poison.encode!
    |> Poison.decode!

    conn = build_conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)

    response = json_response(conn, 201)
    assert response["user"] == expected
    assert response["jwt"]
  end

  test "POST /api/sessions does NOT create a new session given invalid password" do
    create_user
    params = credentials_as_json("bob@example.com", "wrong")

    conn = build_conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)

    assert json_response(conn, 422)
  end

  test "POST /api/sessions does NOT create a new session given invalid email" do
    create_user
    params = credentials_as_json("alice@example.com", "secret")

    conn = build_conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/sessions", params)

    assert json_response(conn, 422)
  end

  test "DELETE /api/session deletes an existing session" do
    conn = authenticated_conn
    |> put_req_header("content-type", "application/json")
    |> delete("/api/session")

    assert json_response(conn, 200)
  end

  test "DELETE /api/session must be authenticated" do
    conn = build_conn
    |> put_req_header("content-type", "application/json")
    |> delete("/api/session")

    assert json_response(conn, 422)
  end

  test "GET /api/session fetches an existing session" do
    user = create_user

    jwt = login_and_get_jwt

    conn = build_conn
    |> put_req_header("authorization", "Bearer #{jwt}")
    |> put_req_header("content-type", "application/json")
    |> get("/api/session")

    expected = %{"user" => user, "jwt" => jwt}
    |> Poison.encode!
    |> Poison.decode!

    assert json_response(conn, 200) == expected
  end

  test "GET /api/session fails with 422 when the JWT auth header is missing" do
    create_user

    conn = build_conn
    |> put_req_header("authorization", "this is not the token you are looking for")
    |> put_req_header("content-type", "application/json")
    |> get("/api/session")

    assert json_response(conn, 422)
  end

  test "GET /api/session fails with 422 when there is no session" do
    conn = build_conn
    |> put_req_header("content-type", "application/json")
    |> get("/api/session")

    assert json_response(conn, 422)
  end
end
