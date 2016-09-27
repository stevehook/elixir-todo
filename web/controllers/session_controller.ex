defmodule Todo.SessionController do
  use Todo.Web, :controller

  alias Todo.User

  plug :scrub_params, "user" when action in [:create]
  plug Guardian.Plug.EnsureAuthenticated, [handler: Todo.SessionController] when action in [:show, :delete]

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case authenticate(email, password) do
      {:ok, user} ->
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, claims} = Guardian.Plug.claims(new_conn)
        exp = Map.get(claims, "exp")

        new_conn
        |> put_status(201)
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> put_resp_header("x-expires", to_string(exp))
        |> json(%{ "user" => Guardian.Plug.current_resource(new_conn), "jwt" => jwt })
      {:error, errors} ->
        conn
        |> put_status(422)
        |> json(%{ "errors" => errors })
    end
  end

  def delete(conn, _params) do
    # TODO - handle users that are not logged in
    conn
    |> put_status(200)
    |> json(%{})
  end

  def show(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{ "user" => Guardian.Plug.current_resource(conn),
               "jwt" => Guardian.Plug.current_token(conn) })
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{})
  end

  defp authenticate(email, password) do
    case Repo.get_by(User, email: email, password: password) do
      nil -> {:error, "Login failed"}
      user -> {:ok, user}
    end
  end
end
