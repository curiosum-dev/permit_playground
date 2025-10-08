defmodule PermitPlayground.RBAC do
  @moduledoc false

  import Contexted.Delegator

  delegate_all(PermitPlayground.RBAC.ActionContext)
  delegate_all(PermitPlayground.RBAC.RoleContext)
  delegate_all(PermitPlayground.RBAC.PermissionContext)
  delegate_all(PermitPlayground.RBAC.ResourceContext)
  delegate_all(PermitPlayground.RBAC.ResourceAttributeContext)
end
