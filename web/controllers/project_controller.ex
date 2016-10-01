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

  def create(conn, %{"project" => project_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = Project.changeset(%Project{}, project_params)
      |> Ecto.Changeset.put_assoc(:users, [user])
    case Repo.insert(changeset) do
      {:ok, project} ->
        conn
        |> put_status(201)
        |> json(project)
      {:error, changeset} ->
        errors = errors_for_json(changeset.errors)
        conn
        |> put_status(422)
        |> json(%{ "errors" => errors })
    end
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    case load_project(id, conn) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})
      project ->
        changeset = Project.changeset(project, project_params)
        case Repo.update(changeset) do
          {:ok, project} ->
            conn
            |> put_status(200)
            |> json(project)
          {:error, changeset} ->
            errors = errors_for_json(changeset.errors)
            conn
            |> put_status(422)
            |> json(%{ "errors" => errors })
        end
    end
  end

  defp errors_for_json(errors) do
    keyword_list = Enum.map(errors,
      fn {field, detail} -> { field, elem(detail, 0) } end)
    Enum.into(keyword_list, %{})
  end

  defp load_project(project_id, conn) do
    user = Guardian.Plug.current_resource(conn)
    query = from t in Project,
      join: u in assoc(t, :users),
      where: u.id == ^user.id
    Repo.get(query, project_id)
  end
end
