defmodule PermitPlayground.Authorization do
  @moduledoc false

  import Contexted.Delegator

  delegate_all(PermitPlayground.Authorization.ActionContext)
  delegate_all(PermitPlayground.Authorization.RoleContext)
  delegate_all(PermitPlayground.Authorization.PermissionContext)
  delegate_all(PermitPlayground.Authorization.ResourceContext)
  delegate_all(PermitPlayground.Authorization.ResourceAttributeContext)
  delegate_all(PermitPlayground.Authorization.UserAttributeContext)
  delegate_all(PermitPlayground.Authorization.RelationshipContext)
end
