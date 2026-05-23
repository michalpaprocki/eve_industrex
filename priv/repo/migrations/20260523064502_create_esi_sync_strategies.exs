defmodule EveIndustrex.Repo.Migrations.CreateEsiSyncStrategy do
  use Ecto.Migration

  def change do
    create table(:esi_sync_strategies) do
      add :target_id, :integer, null: false
      add :sync_interval_seconds, :integer
      add :last_successful_sync, :utc_datetime
      add :enabled, :boolean, default: true, null: false
      timestamps(type: :utc_datetime)
    end

  end
end
