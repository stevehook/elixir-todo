defmodule Todo.TeamControllerTest do
  use Todo.ConnCase
  alias Todo.Team
  alias Todo.Repo

  def create_team(name) do
    { :ok, team } = %Team{name: name}
    |> Repo.insert
    team
  end

  def create_teams_as_json(user) do
    create_team("Office workers")

    house_workers = create_team("House workers")
    |> Repo.preload(:users)
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:users, [user])
    |> Repo.update!

    house_workers
    |> List.wrap
    |> Poison.encode!
  end

  test "GET /api/teams returns a list of current user teams" do
    user = create_user
    teams_as_json = create_teams_as_json(user)
    conn = get authenticated_conn(user), "/api/teams"
    assert response(conn, 200) == teams_as_json
  end

  test "GET /api/teams returns 401 is not authenticated" do
    user = create_user
    create_teams_as_json(user)
    conn = get build_conn, "/api/teams"
    assert response(conn, 422)
  end
end
