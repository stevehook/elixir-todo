defmodule Todo.TeamController do
  use Todo.Web, :controller
  alias Todo.Repo
  alias Todo.Team

  plug Guardian.Plug.EnsureAuthenticated, [handler: Todo.SessionController]

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    query = from t in Team,
      join: u in assoc(t, :users),
      where: u.id == ^user.id

    teams = Repo.all(query)
    conn
    |> put_status(200)
    |> json(teams)
  end
end
