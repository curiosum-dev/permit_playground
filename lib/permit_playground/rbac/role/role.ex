defmodule PermitPlayground.RBAC.Role do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "roles" do
    field :name, :string

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 20)
    |> unique_constraint(:name)
  end
end
