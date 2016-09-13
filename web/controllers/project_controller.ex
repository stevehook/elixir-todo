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

  def show(conn, %{"id" => id}) do
    case load_project(id, conn) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})
      project ->
        conn
        |> put_status(200)
        |> json(project)
    end
  end

  defp load_project(project_id, conn) do
    user = Guardian.Plug.current_resource(conn)
    query = from t in Project,
      join: u in assoc(t, :users),
      where: u.id == ^user.id
    Repo.get(query, project_id)
  end
end
