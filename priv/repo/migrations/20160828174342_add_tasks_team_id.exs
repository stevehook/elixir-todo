defmodule Todo.Repo.Migrations.AddTasksTeamId do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :team_id, references(:teams)
    end
  end
end
