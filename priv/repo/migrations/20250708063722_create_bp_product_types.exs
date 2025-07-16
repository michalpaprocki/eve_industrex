defmodule EveIndustrex.Repo.Migrations.CreateBpProductTypes do
  use Ecto.Migration

  def change do
      create table("bp_product_types", primary_key: false) do
        add :bp_product, references(:types, column: :type_id, type: :bigint)
        add :type, references(:types, column: :type_id, type: :bigint)
      end
  end
end
