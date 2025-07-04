defmodule EveIndustrex.Repo.Migrations.AlterMaterial do
  use Ecto.Migration

  def change do
    drop  index("materials", [:type_id])
    rename table("materials"), :type_id, to: :product_type_id
    alter table("materials") do
      remove :materials
      add :amount, :bigint
      add :material_type_id, :bigint
    end
  end
end
