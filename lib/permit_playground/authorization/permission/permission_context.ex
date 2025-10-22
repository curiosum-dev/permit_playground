defmodule PermitPlayground.Authorization.PermissionContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.Authorization.Permission

  alias PermitPlayground.Authorization
  alias PermitPlayground.Repo
  alias PermitPlayground.Authorization.Permission

  @spec get_permission_by_role_action_resource(integer(), integer(), integer()) ::
          Ecto.Schema.t() | nil
  def get_permission_by_role_action_resource(role_id, action_id, resource_id) do
    Repo.get_by(Permission,
      role_id: role_id,
      action_id: action_id,
      resource_id: resource_id
    )
  end

  @spec get_permission_by_user_attribute_action_resource(integer(), integer(), integer()) ::
          Ecto.Schema.t() | nil
  def get_permission_by_user_attribute_action_resource(user_attribute_id, action_id, resource_id) do
    Repo.get_by(Permission,
      user_attribute_id: user_attribute_id,
      action_id: action_id,
      resource_id: resource_id
    )
  end

  @spec get_permission_matrix() :: map()
  def get_permission_matrix(), do: build_permission_matrix(nil)

  @spec get_permission_matrix(:role | :attribute) :: map()
  def get_permission_matrix(type) when type in [:role, :attribute],
    do: build_permission_matrix(type)

  defp build_permission_matrix(type) do
    roles = Authorization.list_roles()
    actions = Authorization.list_actions()
    user_attributes = Authorization.list_user_attributes()
    relationships = Authorization.list_relationships()
    resources = Authorization.list_resources([:resource_attributes])
    permissions = Authorization.list_permissions()

    permission_map =
      permissions
      |> Enum.into(%{}, fn p ->
        if p.role_id do
          {{p.role_id, p.action_id, p.resource_id}, p}
        else
          {{p.user_attribute_id, p.action_id, p.resource_id}, p}
        end
      end)

    base = %{
      roles: roles,
      actions: actions,
      user_attributes: user_attributes,
      relationships: relationships,
      resources: resources,
      permissions: permission_map,
      type: type
    }

    case type do
      :role -> base
      :attribute -> base
      _ -> Map.put(base, :permissions, %{})
    end
  end

  @spec toggle_permission(integer(), integer(), integer(), map()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def toggle_permission(role_id, action_id, resource_id, conditions \\ %{}) do
    case get_permission_by_role_action_resource(role_id, action_id, resource_id) do
      nil ->
        create_permission(%{
          role_id: role_id,
          action_id: action_id,
          resource_id: resource_id,
          conditions: conditions
        })

      permission ->
        delete_permission(permission)
    end
  end

  @spec has_permission?(integer(), integer(), integer()) :: boolean()
  def has_permission?(role_id, action_id, resource_id) do
    case get_permission_by_role_action_resource(role_id, action_id, resource_id) do
      nil -> false
      _permission -> true
    end
  end
end
