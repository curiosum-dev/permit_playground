defmodule PermitPlayground.Authorization.ActionContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.Authorization.Action
end
