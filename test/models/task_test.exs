defmodule Todo.TaskTest do
  use Todo.ModelCase

  alias Todo.Task

  @valid_attrs %{project_id: 123, archived_at: "2010-04-17", complete_by: "2010-04-17", completed: true, order: 42, title: "some content", user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Task.changeset(%Task{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Task.changeset(%Task{}, @invalid_attrs)
    refute changeset.valid?
  end
end
