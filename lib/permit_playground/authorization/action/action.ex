defmodule PermitPlayground.Authorization.Action do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "actions" do
    field :name, :string

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(action, attrs) do
    action
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 20)
    |> unique_constraint(:name)
  end
end
