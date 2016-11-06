defmodule Todo.TaskControllerTest do
  use ExUnit.Case
  use Todo.ConnCase
  alias Todo.Project
  alias Todo.Task
  alias Todo.Repo

  setup do
    user = create_user
    project = create_project("Learn Elixir", user)
    other_project = create_project("Learn Clojure")
    task = create_task("Read a book", project)
    other_task = create_task("Write come code", other_project)
    {:ok, [
        user: user,
        project: project,
        other_project: other_project,
        task: task,
        other_task: other_task
      ]
    }
  end

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

  def create_task(title, project) do
    { :ok, task } = %Task{title: title, project_id: project.id}
    |> Repo.insert
    task
  end

  def task_as_json(task) do
    task
    |> Poison.encode!
  end

  def new_task_as_json do
    %{ "task" => %Task{title: "Walk the dog"} }
    |> Poison.encode!()
  end

  def task_as_json_list(task) do
    task
    |> List.wrap
    |> Poison.encode!
  end

  describe "GET /api/tasks" do
    test "returns a list of all tasks", %{user: user, task: task} do
      tasks_as_json = task_as_json_list(task)
      conn = get authenticated_conn(user), "/api/tasks"
      assert response(conn, 200) == tasks_as_json
    end
  end

  describe "GET /api/projects/:project_id/tasks" do
    test "returns a list of tasks", %{user: user, project: project, task: task} do
      tasks_as_json = task_as_json_list(task)
      conn = get authenticated_conn(user), "/api/projects/#{project.id}/tasks"
      assert response(conn, 200) == tasks_as_json
    end

    test "requires authentication", %{project: project} do
      conn = get build_conn, "/api/projects/#{project.id}/tasks"
      assert response(conn, 401)
    end

    test "returns 404 for a non-existent project", %{user: user, project: project} do
      conn = get authenticated_conn(user), "/api/projects/#{project.id + 10}/tasks"
      assert response(conn, 404)
    end

    test "returns 404 for a project that I am not a member of", %{user: user, other_project: project} do
      conn = get authenticated_conn(user), "/api/projects/#{project.id}/tasks"
      assert response(conn, 404)
    end
  end

  describe "GET /api/projects/:project_id/tasks/:id" do
    test "returns a single task", %{user: user, project: project, task: task} do
      task_as_json = task_as_json(task)
      conn = get authenticated_conn(user), "/api/projects/#{project.id}/tasks/#{task.id}"
      assert response(conn, 200) == task_as_json
    end

    test "returns 404 for a missing project", %{user: user, project: project, task: task} do
      conn = get authenticated_conn(user), "/api/projects/#{project.id + 10}/tasks/#{task.id}"
      assert response(conn, 404)
    end

    test "returns 404 for a project that I don't belong to", %{user: user, other_project: project, other_task: task} do
      conn = get authenticated_conn(user), "/api/projects/#{project.id + 10}/tasks/#{task.id}"
      assert response(conn, 404)
    end

    test "returns 404 for a missing task", %{user: user, project: project, task: task} do
      conn = get authenticated_conn(user), "/api/projects/#{project.id}/tasks/#{task.id + 10}"
      assert response(conn, 404)
    end
  end

  describe "POST /api/projects/:project_id/tasks" do
    test "creates a new task", %{user: user, project: project} do
      task_as_json = new_task_as_json

      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> post("/api/projects/#{project.id}/tasks", task_as_json)

      assert %{ "title" => "Walk the dog" } = json_response(conn, 201)
    end

    test "requires authenication", %{project: project} do
      task_as_json = new_task_as_json

      conn = build_conn
      |> put_req_header("content-type", "application/json")
      |> post("/api/projects/#{project.id}/tasks", task_as_json)

      assert response(conn, 401)
    end

    test "fails with an error message if we try to create a new task without a title",
        %{user: user, project: project} do
      task_as_json = %{ "task" => %Task{} }
      |> Poison.encode!()

      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> post("/api/projects/#{project.id}/tasks", task_as_json)

      assert %{ "errors" => %{ "title" => "can't be blank" } } = json_response(conn, 422)
    end

    test "returns 404 for a missing project", %{user: user, project: project} do
      task_as_json = new_task_as_json

      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> post("/api/projects/#{project.id + 10}/tasks", task_as_json)

      assert response(conn, 404)
    end
  end

  describe "PATCH /api/projects/:project_id/tasks/:id" do
    test "updates an existing task", %{user: user, project: project, task: task} do
      task_as_json = %{ "task" => %{title: "Wash the car"} }

      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id}/tasks/#{task.id}", task_as_json)

      assert %{ "title" => "Wash the car" } = json_response(conn, 200)
      task = Repo.get!(Task, task.id)
      assert task.title == "Wash the car"
    end

    test "requires authentication", %{project: project, task: task} do
      task_as_json = %{ "task" => %{title: "Wash the car"} }

      conn = build_conn
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id}/tasks/#{task.id}", task_as_json)

      assert response(conn, 401)
    end

    test "returns 404 for a missing project", %{user: user, project: project, task: task} do
      task_as_json = new_task_as_json

      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id + 10}/tasks/#{task.id}", task_as_json)

      assert response(conn, 404)
    end

    test "returns 404 for a missing task", %{user: user, project: project, task: task} do
      task_as_json = new_task_as_json

      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id}/tasks/#{task.id + 10}", task_as_json)

      assert response(conn, 404)
    end
  end

  describe "DELETE /api/tasks/:id" do
    test "deletes an existing task", %{user: user, project: project, task: task} do
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> delete("/api/projects/#{project.id}/tasks/#{task.id}")

      assert json_response(conn, 200)
      task = Repo.get(Task, task.id)
      assert task == nil
    end

    test "requires authentication", %{project: project, task: task} do
      conn = build_conn
      |> put_req_header("content-type", "application/json")
      |> delete("/api/projects/#{project.id}/tasks/#{task.id}")

      assert response(conn, 401)
    end

    test "returns 404 for a missing project", %{user: user, project: project, task: task} do
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> delete("/api/projects/#{project.id + 10}/tasks/#{task.id}")

      assert response(conn, 404)
    end

    test "returns 404 for a missing task", %{user: user, project: project, task: task} do
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> delete("/api/projects/#{project.id}/tasks/#{task.id + 10}")

      assert response(conn, 404)
    end
  end

  describe "PATCH /api/tasks/:id/complete" do
    test "marks an existing task as completed", %{user: user, project: project, task: task} do
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id}/tasks/#{task.id}/complete")

      assert %{ "completed" => true } = json_response(conn, 200)
      task = Repo.get!(Task, task.id)
      assert task.completed == true
    end

    test "requires authentication", %{project: project, task: task} do
      conn = build_conn
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id}/tasks/#{task.id}/complete")

      assert response(conn, 401)
    end

    test "returns 404 for a missing project", %{user: user, project: project, task: task} do
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id + 10}/tasks/#{task.id}/complete")

      assert response(conn, 404)
    end

    test "returns 404 for a missing task", %{user: user, project: project, task: task} do
      conn = authenticated_conn(user)
      |> put_req_header("content-type", "application/json")
      |> patch("/api/projects/#{project.id}/tasks/#{task.id + 10}/complete")

      assert response(conn, 404)
    end
  end
end
