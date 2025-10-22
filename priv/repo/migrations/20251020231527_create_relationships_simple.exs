defmodule PermitPlayground.Repo.Migrations.CreateRelationshipsSimple do
  use Ecto.Migration

  def change do
    create table(:relationships) do
      add :name, :string, null: false
      add :first_object, :string, null: false
      add :second_object, :string, null: false

      timestamps()
    end
  end
end
