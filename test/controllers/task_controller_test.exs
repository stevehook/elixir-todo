defmodule Todo.TaskControllerTest do
  use Todo.ConnCase
  alias Todo.Task
  alias Todo.Repo

  def create_task do
    { :ok, task } = %Task{title: "Walk the dog"}
    |> Repo.insert
    task
  end

  test "GET /api/tasks returns a list of tasks" do
    tasks_as_json = create_task
    |> List.wrap
    |> Poison.encode!

    conn = get conn, "/api/tasks"

    assert response(conn, 200) == tasks_as_json
  end

  test "GET /api/tasks/:id returns a single task" do
    task = create_task
    task_as_json = task
    |> Poison.encode!

    conn = get conn, "/api/tasks/#{task.id}"

    assert response(conn, 200) == task_as_json
  end

  test "POST /api/tasks creates a new task" do
    task_as_json = %{ "task" => %Task{title: "Walk the dog"} }
    |> Poison.encode!()

    conn = conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/tasks", task_as_json)

    assert %{ "title" => "Walk the dog" } = json_response(conn, 201)
  end

  test "POST /api/tasks fails with an error message if we try to create a new task without a title" do
    task_as_json = %{ "task" => %Task{} }
    |> Poison.encode!()

    conn = conn
    |> put_req_header("content-type", "application/json")
    |> post("/api/tasks", task_as_json)

    assert %{ "errors" => %{ "title" => "can't be blank" } } = json_response(conn, 422)
  end

  test "PATCH /api/tasks/:id updates an existing task" do
    task = create_task
    task_as_json = %{ "task" => %{title: "Wash the car"} }

    conn = conn
    |> put_req_header("content-type", "application/json")
    |> patch("/api/tasks/#{task.id}", task_as_json)

    assert %{ "title" => "Wash the car" } = json_response(conn, 200)
    task = Repo.get!(Task, task.id)
    assert task.title == "Wash the car"
  end

  test "DELETE /api/tasks/:id deletes an existing task" do
    task = create_task

    conn = conn
    |> put_req_header("content-type", "application/json")
    |> delete("/api/tasks/#{task.id}")

    assert json_response(conn, 200)
    task = Repo.get(Task, task.id)
    assert task == nil
  end
end
