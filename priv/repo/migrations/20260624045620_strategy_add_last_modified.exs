defmodule EveIndustrex.Repo.Migrations.StrategyAddLastModified do
  use Ecto.Migration

  def change do
    alter table(:esi_sync_strategies) do
      add :last_modified, :utc_datetime
    end
  end
end
