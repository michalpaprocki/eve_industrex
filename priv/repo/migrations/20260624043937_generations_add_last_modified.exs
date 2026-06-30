defmodule EveIndustrex.Repo.Migrations.GenerationsAddLastModified do
  use Ecto.Migration

  def change do
    alter table(:esi_sync_generations) do
      add :snapshot_last_modified, :utc_datetime
    end
  end
end
