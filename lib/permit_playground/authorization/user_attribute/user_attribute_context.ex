defmodule PermitPlayground.Authorization.UserAttributeContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.Authorization.UserAttribute
end
