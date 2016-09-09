defmodule Todo.TaskController do
  use Todo.Web, :controller
  alias Todo.Repo
  alias Todo.Project
  alias Todo.Task

  plug Guardian.Plug.EnsureAuthenticated, [handler: Todo.SessionController]

  defp load_project(project_id, conn) do
    user = Guardian.Plug.current_resource(conn)
    query = from t in Project,
      join: u in assoc(t, :users),
      where: u.id == ^user.id
    Repo.get(query, project_id)
  end

  def index(conn, %{"project_id" => project_id}) do
    case load_project(project_id, conn) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})
      project ->
        project = Repo.preload(project, [:tasks])
        tasks = project.tasks
        conn
        |> put_status(200)
        |> json(tasks)
    end
  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    case load_project(project_id, conn) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})
      project ->
        case Repo.get_by(Task, %{id: id, project_id: project.id}) do
          nil ->
            conn
            |> put_status(404)
            |> json(%{})
          task ->
            conn
            |> put_status(200)
            |> json(task)
        end
    end
  end

  def create(conn, %{"project_id" => project_id, "task" => task_params}) do
    case load_project(project_id, conn) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})
      project ->
        changeset = Task.changeset(%Task{ project_id: project.id }, task_params)
        case Repo.insert(changeset) do
          {:ok, task} ->
            conn
            |> put_status(201)
            |> json(task)
          {:error, changeset} ->
            errors = errors_for_json(changeset.errors)
            conn
            |> put_status(422)
            |> json(%{ "errors" => errors })
        end
    end
  end

  def update(conn, %{"project_id" => project_id, "id" => id, "task" => task_params}) do
    case load_project(project_id, conn) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})
      project ->
        case Repo.get_by(Task, %{id: id, project_id: project.id}) do
          nil ->
            conn
            |> put_status(404)
            |> json(%{})
          task ->
            changeset = Task.changeset(task, task_params)
            case Repo.update(changeset) do
              {:ok, task} ->
                conn
                |> put_status(200)
                |> json(task)
              {:error, changeset} ->
                errors = errors_for_json(changeset.errors)
                conn
                |> put_status(422)
                |> json(%{ "errors" => errors })
            end
        end
    end
  end

  def complete(conn, %{"id" => id}) do
    task = Repo.get!(Task, id)
    changeset = Task.changeset(task, %{"completed" => true})
    case Repo.update(changeset) do
      {:ok, task} ->
        conn
        |> put_status(200)
        |> json(task)
      {:error, changeset} ->
        errors = errors_for_json(changeset.errors)
        conn
        |> put_status(422)
        |> json(%{ "errors" => errors })
    end
  end

  def delete(conn, %{"project_id" => project_id, "id" => id}) do
    case load_project(project_id, conn) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})
      project ->
        case Repo.get_by(Task, %{id: id, project_id: project.id}) do
          nil ->
            conn
            |> put_status(404)
            |> json(%{})
          task ->
            case Repo.delete(task) do
              {:ok, task} ->
                conn
                |> put_status(200)
                |> json(task)
              {:error, changeset} ->
                errors = errors_for_json(changeset.errors)
                conn
                |> put_status(422)
                |> json(%{ "errors" => errors })
            end
        end
    end
  end

  defp errors_for_json(errors) do
    keyword_list = Enum.map(errors,
      fn {field, detail} -> { field, elem(detail, 0) } end)
    Enum.into(keyword_list, %{})
  end
end
