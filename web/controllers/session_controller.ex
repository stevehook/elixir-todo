defmodule Todo.SessionController do
  use Todo.Web, :controller

  alias Todo.User
  alias Todo.UserQuery

  plug :scrub_params, "user" when action in [:create]

  def create(conn, params = %{}) do
  end

  def delete(conn, _params) do
  end
end
