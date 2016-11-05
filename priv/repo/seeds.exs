# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Todo.Repo.insert!(%Todo.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Todo.Repo
alias Todo.User
alias Todo.Project
alias Todo.Task

Repo.delete_all Task
Repo.delete_all User
Repo.delete_all Project

bob = Repo.insert!(%User{ name: "Bob Roberts", email: "bob@example.com", password: "secret" })
alice = Repo.insert!(%User{ name: "Alice Roberts", email: "alice@example.com", password: "secret" })
norman = Repo.insert!(%User{ name: "Norman Roberts", email: "norman@example.com", password: "secret" })

housework = Project.changeset(%Project{}, %{ name: "Housework" })
  |> Ecto.Changeset.put_assoc(:users, [alice, bob])
  |> Repo.insert!
diy = Project.changeset(%Project{}, %{ name: "DIY" })
  |> Ecto.Changeset.put_assoc(:users, [alice, bob, norman])
  |> Repo.insert!
study = Project.changeset(%Project{}, %{ name: "Study" })
  |> Ecto.Changeset.put_assoc(:users, [bob])
  |> Repo.insert!


