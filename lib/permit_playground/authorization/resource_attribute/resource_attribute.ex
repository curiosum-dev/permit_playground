defmodule PermitPlayground.Authorization.ResourceAttribute do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias PermitPlayground.Authorization.Resource

  schema "resource_attributes" do
    field :name, :string

    belongs_to :resource, Resource

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(resource_attribute, attrs) do
    resource_attribute
    |> cast(attrs, [:name, :resource_id])
    |> validate_required([:name])
    |> foreign_key_constraint(:resource_id)
  end
end
