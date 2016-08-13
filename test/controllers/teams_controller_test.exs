defmodule Todo.TeamControllerTest do
  use Todo.ConnCase
  alias Todo.Team
  alias Todo.Repo

  def create_team do
    { :ok, team } = %Team{name: "Houseworkers"}
    |> Repo.insert
    team
  end

  def create_teams_as_json do
    create_team
    |> List.wrap
    |> Poison.encode!
  end

  test "GET /api/teams returns a list of current user teams" do
    teams_as_json = create_teams_as_json
    conn = get authenticated_conn, "/api/teams"
    assert response(conn, 200) == teams_as_json
  end
end
