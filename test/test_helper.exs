ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Todo.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Todo.Repo --quiet)

Ecto.Adapters.SQL.Sandbox.mode(Todo.Repo, :manual)
