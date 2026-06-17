defmodule EveIndustrex.Repo.Migrations.CreateEsiSyncGenerationPage do
  use Ecto.Migration

  def change do
    create table(:esi_sync_generation_pages) do
    add :page_number, :integer
    add :generation_id, references(:esi_sync_generations, on_delete: :delete_all)
    add :status, :string
    add :last_error, :text
    add :attempts, :integer
      timestamps()
    end
     create unique_index(:esi_sync_generation_pages, [:generation_id, :page_number])
  end
end
