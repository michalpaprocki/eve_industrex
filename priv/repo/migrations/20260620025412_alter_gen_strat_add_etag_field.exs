defmodule EveIndustrex.Repo.Migrations.AlterGenStratAddEtagField do
  use Ecto.Migration

  def change do
    alter table(:esi_sync_generations) do
      add :snapshot_etag, :string
      add :snapshot_expires_at, :utc_datetime
    end
    alter table(:esi_sync_strategies) do
      add :last_expires_at, :utc_datetime
      add :last_etag, :string
    end
  end
end
