defmodule Todo.SessionController do
  use Todo.Web, :controller

  alias Todo.User

  plug :scrub_params, "user" when action in [:create]
  plug Guardian.Plug.EnsureAuthenticated, [handler: Todo.SessionController] when action in [:show]

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case authenticate(email, password) do
      {:ok, user} ->
        conn
        |> put_status(201)
        |> Guardian.Plug.sign_in(user)
        |> json(user)
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
    |> json(Guardian.Plug.current_resource(conn))
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(422)
    |> json(%{})
  end

  defp authenticate(email, password) do
    case Repo.get_by(User, email: email, password: password) do
      nil -> {:error, 'Login failed'}
      user -> {:ok, user}
    end
  end
end
