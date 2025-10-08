defmodule PermitPlayground.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:resources, [:name])
  end
end
