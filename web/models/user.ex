defmodule Todo.User do
  use Todo.Web, :model
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string
    field :deleted, :boolean, default: false
    field :last_logged_in_at, Ecto.DateTime

    many_to_many :projects, Todo.Project, join_through: "users_projects", on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(name email password deleted last_logged_in_at)
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

  defimpl Poison.Encoder, for: Todo.User do
    def encode(user, _options) do
      user
      |> Map.from_struct
      |> Map.drop([:__meta__, :__struct__, :projects])
      |> Poison.encode!
    end
  end
end
