defmodule EveIndustrex.Repo.Migrations.AlterEsiSyncGeneration do
  use Ecto.Migration

  def change do
    alter table(:esi_sync_generations) do
      add :pages_total, :integer
      add :pages_completed, :integer
    end

    alter table(:esi_sync_strategies) do
      add :next_generation, :integer
    end
  end
end
