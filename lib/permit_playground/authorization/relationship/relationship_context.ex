defmodule PermitPlayground.Authorization.RelationshipContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.Authorization.Relationship
end
