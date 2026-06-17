defmodule EveIndustrex.Repo.Migrations.AddUniqueEsiSyncGenerations do
  use Ecto.Migration

  def change do
    create unique_index(:esi_sync_generations, [:esi_sync_strategy_id, :target_id, :generation])
    create unique_index(:esi_sync_generation_pages, [:esi_sync_generation_id, :page_number])
  end
end
