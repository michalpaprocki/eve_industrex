defmodule EveIndustrex.Repo.Migrations.CreateLpOffers do
  use Ecto.Migration

  def change do
    create table("lp_offers", primary_key: false) do

      add :offer_id, :bigint, primary_key: true
      add :quantity, :bigint
      add :type_id, :bigint
      add :lp_cost, :bigint
      add :isk_cost, :bigint
      add :req_items, {:array, :bigint}
      timestamps()
    end
    create unique_index(:lp_offers, [:offer_id])
  end
end
