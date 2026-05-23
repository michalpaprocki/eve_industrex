defmodule EveIndustrex.Repo.Migrations.CreateResourceType do
  use Ecto.Migration

  def change do
    create table(:resource_types) do
      add :name, :string
      timestamps(type: :utc_datetime)
    end
    create unique_index(:resource_types, [:name])
    alter table(:esi_sync_strategies) do
      add :resource_type_id, references(:resource_types, on_delete: :delete_all)
    end
    create unique_index(:esi_sync_strategies, [:resource_type_id, :target_id])
    alter table(:esi_sync_generations) do
      add :esi_sync_strategy_id, references(:esi_sync_strategies), null: false
    end
    alter table(:esi_sync_caches) do
      add :esi_sync_strategy_id, references(:esi_sync_strategies), null: false
    end
    create unique_index(:esi_sync_caches, [:esi_sync_strategy_id, :page_number])
  end
end
