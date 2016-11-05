defmodule Todo.Project do
  use Todo.Web, :model
  use Ecto.Schema

  schema "projects" do
    field :name, :string
    many_to_many :users, Todo.User, join_through: "users_projects", on_delete: :delete_all
    has_many :tasks, Todo.Task, on_delete: :delete_all
    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  defimpl Poison.Encoder, for: Todo.Project do
    def encode(project, _options) do
      project
      |> Map.from_struct
      |> Map.drop([:__meta__, :__struct__, :users, :tasks])
      |> Poison.encode!
    end
  end
end

