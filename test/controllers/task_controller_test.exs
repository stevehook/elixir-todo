defmodule Todo.TaskControllerTest do
  use Todo.ConnCase
  alias Todo.Task
  alias Todo.Repo

  test "/index returns a list of tasks" do
    tasks_as_json =
      %Task{title: "Walk the dog"}
      |> Repo.insert
      |> List.wrap
      |> Poison.encode!

    conn = get conn, "/api/tasks"

    assert json_response(conn, 200) == tasks_as_json
  end
end
