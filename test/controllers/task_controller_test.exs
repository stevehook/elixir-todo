defmodule Todo.TaskControllerTest do
  use Todo.ConnCase
  alias Todo.Task
  alias Todo.Repo

  test "/index returns a list of tasks" do
    { :ok, task } = %Task{title: "Walk the dog"}
      |> Repo.insert
    tasks_as_json = task
      |> List.wrap
      |> Poison.encode!

    conn = get conn, "/api/tasks"

    assert response(conn, 200) == tasks_as_json
  end
end
