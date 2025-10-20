defmodule PermitPlayground.Authorization.UserAttribute do
  use Ecto.Schema

  import Ecto.Changeset

  schema "user_attributes" do
    field :name, :string

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(user_attribute, attrs) do
    user_attribute
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
