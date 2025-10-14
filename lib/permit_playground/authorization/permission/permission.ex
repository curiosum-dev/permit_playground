defmodule PermitPlayground.Authorization.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :conditions, :map, default: %{}

    belongs_to :role, PermitPlayground.Authorization.Role
    belongs_to :action, PermitPlayground.Authorization.Action
    belongs_to :resource, PermitPlayground.Authorization.Resource

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:conditions, :role_id, :action_id, :resource_id])
    |> validate_required([:role_id, :action_id, :resource_id])
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:action_id)
    |> foreign_key_constraint(:resource_id)
    |> unique_constraint([:role_id, :action_id, :resource_id])
  end
end
