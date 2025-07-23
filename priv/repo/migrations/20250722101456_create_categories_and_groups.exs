defmodule EveIndustrex.Repo.Migrations.CreateCategoriesAndGroups do
  use Ecto.Migration

  def change do
    create table("categories", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :category_id, :bigint
      add :name, :string
      add :published, :boolean
    end

    create unique_index(:categories, [:category_id])

    create table("groups", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :category_id, references(:categories, column: :category_id, type: :bigint, on_delete: :delete_all)
      add :group_id, :bigint
      add :name, :string
      add :published, :boolean
    end

    create unique_index(:groups, [:group_id])

    alter table("bp_product_types") do
      modify :bp_product, references(:types, column: :type_id, type: :bigint, on_delete: :delete_all), from: references(:types, column: :type_id, type: :bigint)
      modify :type, references(:types, column: :type_id, type: :bigint, on_delete: :delete_all), from: references(:types, column: :type_id, type: :bigint)
    end
    alter table("average_prices") do
      modify :type_id, references(:types, column: :type_id, type: :bigint, on_delete: :delete_all), from: references(:types, column: :type_id, type: :bigint)
    end
    alter table("lp_req_items") do
      modify :type_id, references(:types, column: :type_id, type: :bigint, on_delete: :delete_all), from: references(:types, column: :type_id, type: :bigint)
    end
  end
end
