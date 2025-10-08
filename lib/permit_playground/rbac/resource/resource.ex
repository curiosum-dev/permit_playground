defmodule PermitPlayground.RBAC.Resource do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias PermitPlayground.RBAC.ResourceAttribute

  schema "resources" do
    field :name, :string
    field :resource_attributes_list, :string, virtual: true

    has_many :resource_attributes, ResourceAttribute, on_replace: :delete
    has_many :permissions, PermitPlayground.RBAC.Permission

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name, :resource_attributes_list])
    |> parse_attributes_list()
    |> cast_assoc(:resource_attributes, with: &ResourceAttribute.changeset/2, required: false)
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  # Parse the virtual field and convert it to nested params for cast_assoc
  defp parse_attributes_list(
         %Ecto.Changeset{changes: %{resource_attributes_list: str}} = changeset
       )
       when is_binary(str) and str != "" do
    new_attrs =
      str
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&%{name: &1})

    existing_attrs =
      case changeset.data.resource_attributes do
        attrs when is_list(attrs) -> Enum.map(attrs, &Map.take(&1, [:id, :name]))
        _ -> []
      end

    put_change(changeset, :resource_attributes, existing_attrs ++ new_attrs)
  end

  defp parse_attributes_list(changeset), do: changeset
end
