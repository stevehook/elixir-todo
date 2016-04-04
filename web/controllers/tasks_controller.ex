defmodule Todo.TasksController do
  use Todo.Web, :controller
  alias Todo.Repo
  alias Todo.Task

  def index(conn, _params) do
    tasks = Repo.all(Task)
    conn
    |> put_status(200)
    |> json(tasks)
  end

  def show(conn, %{"id" => id}) do
    task = Repo.get!(Task, id)
    conn
    |> put_status(200)
    |> json(task)
  end

  def create(conn, %{"task" => task_params}) do
    changeset = Task.changeset(%Task{}, task_params)
    {:ok, task} = Repo.insert(changeset)
    conn
    |> put_status(201)
    |> json(task)
  end
end
