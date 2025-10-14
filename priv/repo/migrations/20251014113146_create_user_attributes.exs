defmodule PermitPlayground.Repo.Migrations.CreateUserAttributes do
  use Ecto.Migration

  def change do
    create table(:user_attributes) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:user_attributes, [:name])
  end
end
