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


Repo.insert!(%Task{ title: "Grocery shopping", completed: true, project_id: housework.id })
Repo.insert!(%Task{ title: "Cook dinner", project_id: housework.id })
Repo.insert!(%Task{ title: "Walk the dog", project_id: housework.id })
Repo.insert!(%Task{ title: "Washing up", project_id: housework.id })
Repo.insert!(%Task{ title: "Make the bed", project_id: housework.id })

Repo.insert!(%Task{ title: "Fix the leaky tap", completed: true, project_id: diy.id })
Repo.insert!(%Task{ title: "Paint the spare room", completed: true, project_id: diy.id })
Repo.insert!(%Task{ title: "Put up the shelves", project_id: diy.id })

Repo.insert!(%Task{ title: "Learn Ruby", completed: true, project_id: study.id })
Repo.insert!(%Task{ title: "Learn Node.js", project_id: study.id })
Repo.insert!(%Task{ title: "Learn Elixir", project_id: study.id })
Repo.insert!(%Task{ title: "Learn Phoenix", project_id: study.id })

