defmodule Todo.Repo.Migrations.AddDeleteCascadeRules do
  use Ecto.Migration

  def change do
    alter table(:users_projects) do
      modify :user_id, references(:users), null: false, on_delete: :delete_all
      modify :project_id, references(:projects), null: false, on_delete: :delete_all
    end

    alter table(:tasks) do
      modify :project_id, references(:projects), null: false, on_delete: :delete_all
    end
  end
end
