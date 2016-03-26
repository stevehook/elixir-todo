defmodule Todo.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :completed, :boolean, default: false
      add :complete_by, :date
      add :order, :integer
      add :archived_at, :date
      add :user_id, :integer

      timestamps
    end

  end
end
