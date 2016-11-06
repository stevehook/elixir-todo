defmodule Todo.TaskController do
  use Todo.Web, :controller
  alias Todo.Repo
  alias Todo.Project
  alias Todo.Task

  plug Guardian.Plug.EnsureAuthenticated, [handler: Todo.SessionController]

  def index(conn, %{}) do
    user = Guardian.Plug.current_resource(conn)

    query = from t in Task,
      join: p in assoc(t, :project),
      join: u in assoc(p, :users),
      where: u.id == ^user.id

    tasks = Repo.all(query)
    conn
    |> put_status(200)
    |> json(tasks)
  end
end
