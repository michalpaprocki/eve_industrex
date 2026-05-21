defmodule EveIndustrex.Repo.Migrations.CreateBlueprintActivity do
  use Ecto.Migration

  def change do
    create table(:blueprint_activities) do
      add :activity_type, :string, null: false
      add :time, :bigint, null: false
      add :blueprint_type_id, references(:blueprints, column: :blueprint_type_id, type: :bigint, on_delete: :delete_all), null: false
      timestamps()
    end
    create unique_index(:blueprint_activities, [:blueprint_type_id, :activity_type]
           )

    create index(:blueprint_activities, [:blueprint_type_id])
  end
end
