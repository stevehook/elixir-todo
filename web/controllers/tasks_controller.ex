defmodule Todo.TasksController do
  use Todo.Web, :controller
  alias Todo.Repo
  alias Todo.Task

  def index(conn, _params) do
    tasks = Repo.all(Task)
    render conn, tasks: tasks
  end
end
