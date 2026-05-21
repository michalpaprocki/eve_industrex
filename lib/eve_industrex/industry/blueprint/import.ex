defmodule EveIndustrex.Industry.Blueprint.Import do
  alias EveIndustrex.Industry.Blueprint.Persistence
  alias EveIndustrex.Industry.Blueprint.Mapper
  alias EveIndustrex.Infrastructure.Parsers.Jsonl

  def from_dump() do
    data = Jsonl.read_jsonl(Jsonl.get_bp_path)
    blueprints = Enum.map(data, fn d -> Mapper.from_dump(d) end)

    Persistence.upsert_all(blueprints)
    Enum.map(blueprints |> Enum.chunk_every(1000), fn chunk -> EveIndustrex.Industry.BlueprintActivity.Persistance.upsert_all(chunk) end)
    Enum.map(blueprints |> Enum.chunk_every(1000), fn chunk -> EveIndustrex.Industry.BlueprintActivityMaterial.Persistence.upsert_all(chunk) end)
    Enum.map(blueprints |> Enum.chunk_every(1000), fn chunk -> EveIndustrex.Industry.BlueprintActivityProduct.Persistence.upsert_all(chunk) end)
    Enum.map(blueprints |> Enum.chunk_every(1000), fn chunk -> EveIndustrex.Industry.BlueprintActivitySkill.Persistence.upsert_all(chunk) end)
  end
end
