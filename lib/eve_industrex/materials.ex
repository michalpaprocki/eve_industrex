defmodule EveIndustrex.Materials do

  alias EveIndustrex.Schemas.{Material}
  alias EveIndustrex.Repo
  import Ecto.Query

  def insert_materials_from_dump() do
    mats = EveIndustrex.Parser.parse_materials()
    Repo.delete_all(Material)
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, mats, fn {pid, mats} ->
      Enum.map(elem(mats, 1), fn m ->
          %Material{amount: elem(m, 0), product_type_id: pid, material_type_id: elem(m, 1)} |> Repo.insert()
      end)
    end) |> Stream.run()


  end

  def insert_material(attrs) do
    %Material{} |> Material.changeset(attrs) |> Repo.insert()
  end
  def get_type_materials(type_id) do
    from(m in Material, join: t in assoc(m, :product_type), where: t.type_id == ^type_id, preload: :material_type) |> Repo.all()
  end
  def get_product_materials_from_type_id_list(type_ids) do
    from(m in Material, where: m.product_type_id in ^type_ids, preload: :material_type) |> Repo.all
  end
  def get_product_materials_ids_from_type_id_list(type_ids) do
    from(m in Material, where: m.product_type_id in ^type_ids, select: [m.material_type_id]) |> Repo.all
  end
  def get_materials_from_type_id_list(type_ids) do
    from(m in Material, join: t in assoc(m, :product_type), where: t.type_id in ^type_ids, preload: :material_type) |> Repo.all()
  end
  def read_materials_all() do
    from(m in Material, preload: [:material_type, :product_type]) |> Repo.all()
  end
    def remove_materials_all(), do: Repo.delete_all(Material)
end
