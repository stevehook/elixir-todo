defmodule Todo.TaskControllerTest do
  use Todo.ConnCase
  alias Todo.Task
  alias Todo.Repo

  test "GET /api/tasks returns a list of tasks" do
    { :ok, task } = %Task{title: "Walk the dog"}
      |> Repo.insert
    tasks_as_json = task
      |> List.wrap
      |> Poison.encode!

    conn = get conn, "/api/tasks"

    assert response(conn, 200) == tasks_as_json
  end

  test "GET /api/tasks/:id returns a single task" do
    { :ok, task } = %Task{title: "Walk the dog"}
      |> Repo.insert
    task_as_json = task
      |> Poison.encode!

    conn = get conn, "/api/tasks/#{task.id}"

    assert response(conn, 200) == task_as_json
  end
end
