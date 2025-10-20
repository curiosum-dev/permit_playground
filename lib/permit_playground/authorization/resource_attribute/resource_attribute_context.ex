defmodule PermitPlayground.Authorization.ResourceAttributeContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.Authorization.ResourceAttribute
end
