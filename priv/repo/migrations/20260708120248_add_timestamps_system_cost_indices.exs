defmodule EveIndustrex.Repo.Migrations.AddTimestampsSystemCostIndices do
  use Ecto.Migration

  def change do
    alter table(:system_cost_indices) do
      timestamps()
    end
  end
end
