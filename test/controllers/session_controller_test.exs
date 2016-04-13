defmodule Todo.SessionControllerTest do
  use Todo.ConnCase
  alias Todo.User
  alias Todo.Repo

  def create_user do
    { :ok, user } = %User{name: "Bob Roberts", email: "bob@example.com", password: "secret"}
    |> Repo.insert
    user
  end

  @tag :pending
  test "POST /api/sessions creates a new session given valid credentials" do
    user = create_user
    conn = conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/session", %{email: "bob@example.com", password: "secret"})

    assert json_response(conn, 201)
  end

  @tag :pending
  test "POST /api/sessions does NOT create a new session given invalid credentials" do
  end

  @tag :pending
  test "DELETE /api/sessions deletes an existing session" do
  end
end
