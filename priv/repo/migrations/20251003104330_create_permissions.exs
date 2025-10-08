defmodule PermitPlayground.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :conditions, :map, default: %{}
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :action_id, references(:actions, on_delete: :delete_all), null: false
      add :resource_id, references(:resources, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:permissions, [:role_id])
    create index(:permissions, [:action_id])
    create index(:permissions, [:resource_id])
    create unique_index(:permissions, [:role_id, :action_id, :resource_id])
  end
end
