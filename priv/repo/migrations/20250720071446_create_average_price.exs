defmodule EveIndustrex.Repo.Migrations.CreateAveragePrice do
  use Ecto.Migration
  def change do
    create table("average_prices", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :adjusted_price, :float
      add :average_price, :float
      add :type_id, references(:types, column: :type_id, type: :bigint)
      timestamps()
    end

    alter table("types") do
      add :average_price_id, :bigint
    end
  end
end
