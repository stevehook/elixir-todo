defmodule Todo.Task do
  use Todo.Web, :model

  schema "tasks" do
    field :title, :string
    field :completed, :boolean, default: false
    field :complete_by, Ecto.Date
    field :order, :integer
    field :archived_at, Ecto.Date
    field :user_id, :integer

    timestamps
  end

  @required_fields ~w(title completed complete_by order archived_at user_id)
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

  defimpl Poison.Encoder, for: Todo.Task do
    def encode(task, _options) do
      task
      |> Map.from_struct
      |> Map.drop([:__meta__, :__struct__])
      |> Poison.encode!
    end
  end
end
