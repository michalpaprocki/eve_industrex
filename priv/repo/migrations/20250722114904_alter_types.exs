defmodule EveIndustrex.Repo.Migrations.AlterTypes do
  use Ecto.Migration

  def change do
    alter table("types") do
      modify :group_id, references(:groups, column: :group_id, type: :bigint), null: false, from: :bigint
    end
  end
end
