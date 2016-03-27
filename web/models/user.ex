defmodule Todo.User do
  use Todo.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :deleted, :boolean, default: false
    field :last_logged_in_at, Ecto.DateTime

    timestamps
  end

  @required_fields ~w(name email deleted last_logged_in_at)
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
end
