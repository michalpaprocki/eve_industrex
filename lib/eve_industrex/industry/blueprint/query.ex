defmodule EveIndustrex.Industry.Blueprint.Query do
  import Ecto.Query
  alias EveIndustrex.Industry.{Blueprint, BlueprintActivityProduct}

  alias EveIndustrex.Repo
  @moduledoc false
  def get_blueprints(), do: Repo.all(Blueprint) |> Repo.preload([:type])

  def get_blueprint(blueprint_type_id),
    do: Repo.get_by(Blueprint, blueprint_type_id: blueprint_type_id)

  def get_blueprint_product(bp_type_id),
    do:
      from(bpp in BlueprintActivityProduct,
        where: bpp.blueprint_type_id == ^bp_type_id and bpp.activity_type == :manufacturing
      )
      |> Repo.one()
      |> Repo.preload(:type)

  def get_blueprint_for_cache() do
    from(b in Blueprint,
      join: t in assoc(b, :type),
      join: a in assoc(b, :activities),
      where: t.published == true,
      preload: [:type, :activities, activities: [:materials, :products]]
    )
    |> Repo.all()
  end
end
