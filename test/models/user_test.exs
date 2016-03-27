defmodule Todo.UserTest do
  use Todo.ModelCase

  alias Todo.User

  @valid_attrs %{deleted: true, email: "some content", last_logged_in_at: "2010-04-17 14:00:00", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
