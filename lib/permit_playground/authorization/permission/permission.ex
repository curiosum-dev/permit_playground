defmodule PermitPlayground.Authorization.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  alias PermitPlayground.Authorization.Role
  alias PermitPlayground.Authorization.UserAttribute
  alias PermitPlayground.Authorization.Action
  alias PermitPlayground.Authorization.Resource

  schema "permissions" do
    field :conditions, :map, default: %{}

    belongs_to :role, Role
    belongs_to :user_attribute, UserAttribute
    belongs_to :action, Action
    belongs_to :resource, Resource

    timestamps()
  end

  @required_fields ~w(action_id resource_id)a
  @optional_fields ~w(role_id user_attribute_id conditions)a

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:user_attribute_id)
    |> foreign_key_constraint(:action_id)
    |> foreign_key_constraint(:resource_id)
    |> unique_constraint([:role_id, :action_id, :resource_id])
    |> unique_constraint([:user_attribute_id, :action_id, :resource_id])
  end
end
