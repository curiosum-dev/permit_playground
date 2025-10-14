defmodule PermitPlayground.Authorization.ResourceContext do
  @moduledoc false
  use Contexted.CRUD,
    repo: PermitPlayground.Repo,
    schema: PermitPlayground.Authorization.Resource,
    exclude: [:get, :list]

  alias PermitPlayground.Repo
  alias PermitPlayground.Authorization.Resource

  @spec list_resources(list()) :: list()
  def list_resources(preloads \\ []) do
    Resource
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @spec get_resource!(integer(), list()) :: Ecto.Schema.t()
  def get_resource!(id, preloads \\ []) do
    Resource
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end
end
