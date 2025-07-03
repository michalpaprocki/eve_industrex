defmodule EveIndustrex.Materials do
  alias EveIndustrex.Types
  alias EveIndustrex.Schemas.Material
  alias EveIndustrex.Repo
  import Ecto.Query
  def get_materials(type_id) do
    materials = Repo.get_by(Material, type_id: type_id)
    materials_into_term = Map.replace(materials, :materials, :erlang.binary_to_term(materials.materials))
    Enum.map(elem(materials_into_term.materials, 1), fn m -> {Types.get_type(elem(m, 1)), elem(m, 0)} end)
  end
  def get_materials_from_type_id_list(type_ids) do
    materials = from(m in Material, where: m.type_id in ^type_ids) |> Repo.all()
    materials_into_term = Enum.map(materials, fn m -> Map.replace(m, :materials, :erlang.binary_to_term(m.materials)) end)
    materials_into_term
  end
end
