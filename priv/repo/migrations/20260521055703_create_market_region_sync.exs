defmodule EveIndustrex.Repo.Migrations.CreateMarketRegionSync do
  use Ecto.Migration

  def change do
    create table(:market_region_syncs) do
      add :region_id, :integer
      add :etag, :string
      add :expires_at, :utc_datetime
      add :last_successfull_sync_at, :utc_datetime
      add :status, :string
      add :pages, :integer
      add :error_count, :integer
    end
  end
end
