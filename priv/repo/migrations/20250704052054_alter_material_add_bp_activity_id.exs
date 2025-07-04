defmodule EveIndustrex.Repo.Migrations.AlterMaterialAddBpActivityId do
  use Ecto.Migration

  def change do
    alter table("materials") do
      add :blueprint_activity_id, :binary_id
    end
  end
end
