defmodule PermitPlayground.Authorization.Relationship do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "relationships" do
    field :name, Ecto.Enum, values: [:ownership, :superiority, :followup]
    field :first_object, :string
    field :second_object, :string

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:name, :first_object, :second_object])
    |> validate_required([:name, :first_object, :second_object])
  end
end
