defmodule Todo.SessionController do
  use Todo.Web, :controller

  alias Todo.User
  alias Todo.UserQuery

  plug :scrub_params, "user" when action in [:create]

  def create(conn, params = %{"user" => %{"email" => email, "password" => password}}) do
    case authenticate(email, password) do
      {:ok, user} ->
        IO.inspect user
        conn
        |> put_status(201)
        |> json(user)
      {:error, errors} ->
        conn
        |> put_status(422)
        |> json(%{ "errors" => errors })
    end
  end

  def delete(conn, _params) do
  end

  defp authenticate(email, password) do
    user = Repo.get_by(User, %{email: email, password: password})
    {:ok, user}
  end
end
