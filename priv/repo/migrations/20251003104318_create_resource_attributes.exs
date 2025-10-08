defmodule PermitPlayground.Repo.Migrations.CreateResourceAttributes do
  use Ecto.Migration

  def change do
    create table(:resource_attributes) do
      add :name, :string, null: false
      add :resource_id, references(:resources, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:resource_attributes, [:resource_id])
    create unique_index(:resource_attributes, [:resource_id, :name])
  end
end
