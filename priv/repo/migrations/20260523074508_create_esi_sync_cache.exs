defmodule EveIndustrex.Repo.Migrations.CreateEsiSyncCache do
  use Ecto.Migration

  def change do
    create table(:esi_sync_caches) do
      add :etag, :string
      add :expires_at, :utc_datetime
      add :page_number, :integer
      add :last_checked_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end

  end
end
