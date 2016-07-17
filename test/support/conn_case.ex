defmodule Todo.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Todo.User
      alias Todo.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      import Todo.Router.Helpers

      # The default endpoint for testing
      @endpoint Todo.Endpoint

      def create_user do
        { :ok, user } = %User{name: "Bob Roberts", email: "bob@example.com", password: "secret"}
        |> Repo.insert
        user
      end

      def credentials_as_json(email, password) do
        %{ "user" => %{"email" => email, "password" => password} }
        |> Poison.encode!()
      end

      def login_and_get_jwt do
        params = credentials_as_json("bob@example.com", "secret")
        login_conn = Phoenix.ConnTest.conn()
        |> put_req_header("content-type", "application/json")
        |> post("/api/sessions", params)
        Guardian.Plug.current_token(login_conn)
      end

      def authenticated_conn do
        create_user
        jwt = login_and_get_jwt

        conn = conn
        |> put_req_header("authorization", jwt)
        |> put_req_header("content-type", "application/json")
      end
    end
  end

  setup tags do
    unless tags[:async] do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Todo.Repo)
    end

    {:ok, conn: Phoenix.ConnTest.conn()}
  end
end
