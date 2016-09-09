defmodule Todo.Repo.Migrations.RenameTeamsToProjects do
  use Ecto.Migration

  def change do
    rename table(:teams), to: table(:projects)
    rename table(:users_teams), to: table(:users_projects)
    rename table(:tasks), :team_id, to: :project_id
    rename table(:users_projects), :team_id, to: :project_id
  end
end
