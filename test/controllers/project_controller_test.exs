defmodule Todo.ProjectControllerTest do
  use Todo.ConnCase
  alias Todo.Project
  alias Todo.Repo

  def create_project(name) do
    { :ok, project } = %Project{name: name}
    |> Repo.insert
    project
  end

  def create_projects_as_json(user) do
    create_project("Office workers")

    house_workers = create_project("House workers")
    |> Repo.preload(:users)
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:users, [user])
    |> Repo.update!

    house_workers
    |> List.wrap
    |> Poison.encode!
  end

  test "GET /api/projects returns a list of current user projects" do
    user = create_user
    projects_as_json = create_projects_as_json(user)
    conn = get authenticated_conn(user), "/api/projects"
    assert response(conn, 200) == projects_as_json
  end

  test "GET /api/projects returns 401 is not authenticated" do
    user = create_user
    create_projects_as_json(user)
    conn = get build_conn, "/api/projects"
    assert response(conn, 422)
  end
end
