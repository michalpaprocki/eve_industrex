defmodule EveIndustrex.Repo.Migrations.CreateEsiSyncGenerations do
  use Ecto.Migration

  def change do
    create table(:esi_sync_generations) do
      add :priority, :integer
      add :generation, :integer
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime
      add :duration_ms, :integer
      add :target_id, :integer
      add :status, :string, null: false
      add :last_error, :string
      timestamps(type: :utc_datetime)
    end
  end
end
