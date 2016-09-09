defmodule Todo.ProjectController do
  use Todo.Web, :controller
  alias Todo.Repo
  alias Todo.Project

  plug Guardian.Plug.EnsureAuthenticated, [handler: Todo.SessionController]

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    query = from t in Project,
      join: u in assoc(t, :users),
      where: u.id == ^user.id

    projects = Repo.all(query)
    conn
    |> put_status(200)
    |> json(projects)
  end
end
