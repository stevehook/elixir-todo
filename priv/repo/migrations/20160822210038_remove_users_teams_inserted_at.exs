defmodule Todo.Repo.Migrations.RemoveUsersTeamsInsertedAt do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE users_teams ALTER COLUMN inserted_at SET DEFAULT now();"
    execute "ALTER TABLE users_teams ALTER COLUMN updated_at SET DEFAULT now();"
  end
end
