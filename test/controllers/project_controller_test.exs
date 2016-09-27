defmodule Todo.ProjectControllerTest do
  use Todo.ConnCase
  alias Todo.Project
  alias Todo.Repo

  def create_project(name, user \\ nil) do
    { :ok, project } = %Project{name: name}
    |> Repo.insert

    if user do
      project
      |> Repo.preload(:users)
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:users, [user])
      |> Repo.update!
    end

    project
  end

  def create_projects_as_json(user) do
    create_project("Office workers")

    house_workers = create_project("House workers", user)

    house_workers
    |> List.wrap
    |> Poison.encode!
  end

  def create_project_as_json(user) do
    house_workers = create_project("House workers", user)
    house_workers
    |> Poison.encode!
  end

  describe "GET /api/projects" do
    test "returns a list of current user projects" do
      user = create_user
      projects_as_json = create_projects_as_json(user)
      conn = get authenticated_conn(user), "/api/projects"
      assert response(conn, 200) == projects_as_json
    end

    test "returns 401 if not authenticated" do
      user = create_user
      create_projects_as_json(user)
      conn = get build_conn, "/api/projects"
      assert response(conn, 401)
    end
  end

  describe "POST /api/projects" do
    test "creates a new project for the current user" do
      user = create_user

      project_as_json = %{"project" => %Project{name: "My project"}} |> Poison.encode!
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> post("/api/projects", project_as_json)

      assert %{ "id" => project_id, "name" => "My project" } = json_response(conn, 201)

      project = Repo.get!(Project, project_id) |> Repo.preload(:users)
      assert Enum.count(project.users) == 1
    end

    test "returns 401 if not authenticated" do
      project_as_json = %{"project" => %Project{name: "My project"}} |> Poison.encode!
      conn = build_conn
      |> put_req_header("content-type", "application/json")
      |> post("/api/projects", project_as_json)

      assert response(conn, 401)
    end

    test "returns 422 if inputs are invalid" do
      user = create_user

      project_as_json = %{"project" => %Project{}} |> Poison.encode!
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> post("/api/projects", project_as_json)

      assert response(conn, 422)
    end
  end

  describe "GET /api/projects/:id" do
    test "returns a given projects" do
      user = create_user
      project = create_project("My project", user)
      project_as_json = project |> Poison.encode!
      conn = get authenticated_conn(user), "/api/projects/#{project.id}"
      assert response(conn, 200) == project_as_json
    end

    test "returns 401 if not authenticated" do
      user = create_user
      project = create_project("My project", user)
      conn = get build_conn, "/api/projects/#{project.id}"
      assert response(conn, 401)
    end

    test "returns 404 if project missing" do
      user = create_user
      project = create_project("My project", user)
      conn = get authenticated_conn(user), "/api/projects/#{project.id + 10}"
      assert response(conn, 404)
    end

    test "returns 404 if user is not a member of the project" do
      user = create_user
      project = create_project("My project")
      conn = get authenticated_conn(user), "/api/projects/#{project.id}"
      assert response(conn, 404)
    end
  end

  describe "PATCH /api/projects/:id" do
  end

  describe "DELETE /api/projects/:id" do
  end
end
