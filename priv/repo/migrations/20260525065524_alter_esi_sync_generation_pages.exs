defmodule EveIndustrex.Repo.Migrations.AlterEsiSyncGenerationPages do
  use Ecto.Migration

  def change do
    alter table(:esi_sync_generation_pages) do
      add :esi_sync_generation_id, references(:esi_sync_generations, on_delete: :delete_all), null: false
    end
  end
end
