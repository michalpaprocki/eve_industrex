defmodule EveIndustrex.Repo.Migrations.CreateteSysCostIndices do
  use Ecto.Migration

  def change do
    create table(:system_cost_indices) do
      add :cost_index, :float
      add :activity, :string
      add :system_id, references(:systems, column: :system_id, type: :integer), null: false
    end
    create unique_index(:system_cost_indices, [:activity, :system_id])
  end
end
