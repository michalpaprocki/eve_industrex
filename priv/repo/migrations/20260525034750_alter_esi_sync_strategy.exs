defmodule EveIndustrex.Repo.Migrations.AlterEsiSyncStrategy do
  use Ecto.Migration

  def change do
    alter table(:esi_sync_strategies) do
      add :status, :string
      add :next_run_at, :utc_datetime
    end
  end
end
