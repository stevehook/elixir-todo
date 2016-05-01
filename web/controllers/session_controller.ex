defmodule Todo.SessionController do
  use Todo.Web, :controller

  alias Todo.User

  plug :scrub_params, "user" when action in [:create]

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case authenticate(email, password) do
      {:ok, user} ->
        conn
        |> put_status(201)
        |> json(user)
      {:error, errors} ->
        conn
        |> put_status(422)
        |> json(%{ "errors" => errors })
    end
  end

  def delete(_conn, _params) do
  end

  defp authenticate(email, password) do
    user = Repo.get_by(User, %{email: email, password: password})
    {:ok, user}
  end
end
