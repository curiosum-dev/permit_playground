defmodule PermitPlayground.RBAC.RoleContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.RBAC.Role
end
