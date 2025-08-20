defmodule EveIndustrex.Repo.Migrations.CreateMarketGroupRelationships do
  use Ecto.Migration

  def change do
    create table("market_group_relationships", primary_key: false) do
      add :parent_id, references(:market_groups, type: :binary_id, on_delete: :delete_all)
      add :child_id, references(:market_groups, type: :binary_id, on_delete: :delete_all)
    end
  end
end
