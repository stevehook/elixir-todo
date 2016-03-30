defmodule Todo.TaskControllerTest do
  use Todo.ConnCase
  alias Todo.Task
  alias Todo.Repo

  test "/index returns a list of tasks" do
    tasks_as_json =
      %Task{title: "Walk the dog"}
      |> Repo.insert
      |> Tuple.to_list
      |> List.last
      |> List.wrap
      |> Poison.encode!
      |> Poison.decode!

    conn = get conn, "/api/tasks"

    assert json_response(conn, 200) == tasks_as_json
  end
end
