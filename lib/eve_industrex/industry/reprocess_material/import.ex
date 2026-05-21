defmodule EveIndustrex.Industry.ReprocessMaterial.Import do
  alias EveIndustrex.Industry.ReprocessMaterial.Persistence
  alias EveIndustrex.Industry.ReprocessMaterial.Mapper
  alias EveIndustrex.Infrastructure.Parsers.Jsonl
  def from_dump() do
    data = Jsonl.read_jsonl(Jsonl.get_type_materials_path)
    materials = Enum.map(data, fn d ->
      Mapper.from_dump(d)
    end)

      Persistence.upsert_all(materials)

  end
end
