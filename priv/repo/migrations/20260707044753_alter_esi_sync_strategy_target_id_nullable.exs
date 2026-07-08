defmodule EveIndustrex.Repo.Migrations.AlterEsiSyncStrategyTargetIdNullable do
  use Ecto.Migration

  def change do
    alter table(:esi_sync_strategies) do
      modify :target_id, :integer, null: true
    end
  end
end
