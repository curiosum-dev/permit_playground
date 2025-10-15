defmodule PermitPlayground.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :conditions, :map, default: %{}
      add :role_id, references(:roles, on_delete: :delete_all), null: true
      add :user_attribute_id, references(:user_attributes, on_delete: :delete_all), null: true
      add :action_id, references(:actions, on_delete: :delete_all), null: false
      add :resource_id, references(:resources, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:permissions, [:role_id])
    create index(:permissions, [:user_attribute_id])
    create index(:permissions, [:action_id])
    create index(:permissions, [:resource_id])
    create unique_index(:permissions, [:role_id, :action_id, :resource_id], name: :permissions_role_action_resource_index)
    create unique_index(:permissions, [:user_attribute_id, :action_id, :resource_id], name: :permissions_user_attribute_action_resource_index)
  end
end
