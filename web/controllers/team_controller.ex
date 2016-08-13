defmodule Todo.TeamController do
  use Todo.Web, :controller
  alias Todo.Repo
  alias Todo.Team

  plug Guardian.Plug.EnsureAuthenticated, [handler: Todo.SessionController]

  def index(conn, _params) do
    teams = Repo.all(Team)
    conn
    |> put_status(200)
    |> json(teams)
  end
end
