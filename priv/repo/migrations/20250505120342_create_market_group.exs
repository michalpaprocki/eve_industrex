defmodule EveIndustrex.Repo.Migrations.CreateMarketGroup do
  use Ecto.Migration

  def change do
    create table("market_groups", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :market_group_id, :bigint
      add :types, {:array, :bigint}
      add :parent_group_id, :bigint

      timestamps()
    end
    create unique_index(:market_groups, [:market_group_id])

  end
end
