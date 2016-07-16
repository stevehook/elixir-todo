defmodule Todo.Repo.Migrations.AddTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      timestamps
    end

    create table(:users_teams) do
      add :user_id, :integer, null: false
      add :team_id, :integer, null: false
      timestamps
    end
  end
end
