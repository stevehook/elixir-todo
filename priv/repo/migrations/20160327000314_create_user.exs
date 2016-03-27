defmodule Todo.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :deleted, :boolean, default: false, null: false
      add :last_logged_in_at, :datetime

      timestamps
    end

  end
end
