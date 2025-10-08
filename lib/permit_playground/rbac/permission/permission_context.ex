defmodule PermitPlayground.RBAC.PermissionContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.RBAC.Permission

  alias PermitPlayground.RBAC
  alias PermitPlayground.Repo
  alias PermitPlayground.RBAC.Permission

  @spec get_permission_by_role_action_resource(integer(), integer(), integer()) ::
          Ecto.Schema.t() | nil
  def get_permission_by_role_action_resource(role_id, action_id, resource_id) do
    Repo.get_by(Permission,
      role_id: role_id,
      action_id: action_id,
      resource_id: resource_id
    )
  end

  @spec get_permission_matrix() :: map()
  def get_permission_matrix do
    roles = RBAC.list_roles()
    actions = RBAC.list_actions()
    resources = RBAC.list_resources([:resource_attributes])
    permissions = RBAC.list_permissions()

    permission_map =
      permissions
      |> Enum.into(%{}, fn p ->
        {{p.role_id, p.action_id, p.resource_id}, p}
      end)

    %{
      roles: roles,
      actions: actions,
      resources: resources,
      permissions: permission_map
    }
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
