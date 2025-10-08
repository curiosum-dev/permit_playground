defmodule PermitPlayground.RBAC.ActionContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.RBAC.Action
end
