defmodule EveIndustrex.Repo.Migrations.CreateType do
  use Ecto.Migration

  def change do

    create table("types", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :capacity, :float
      add :icon_id, :integer
      add :mass, :float
      add :name, :string
      add :description, :text
      add :packaged_volume, :float
      add :group_id, :bigint
      add :portion_size, :integer
      add :published, :boolean
      add :radius, :float
      add :type_id, :bigint
      add :volume, :float
      add :market_group_id, references(:market_groups, column: :market_group_id, type: :bigint), null: true

      timestamps()
    end
    create unique_index(:types, [:type_id])

  end
end
