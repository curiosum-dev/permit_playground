defmodule PermitPlayground.RBAC.ResourceAttributeContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.RBAC.ResourceAttribute
end
