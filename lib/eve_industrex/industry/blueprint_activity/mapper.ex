defmodule EveIndustrex.Industry.BlueprintActivity.Mapper do

  def from_dump({"copying", %{} = map}) do
    %{
      activity_type: :copying,
      time: Map.get(map, "time")
    }
  end
  def from_dump({"manufacturing", %{"materials" => mats, "products" => prods, "skills" => skills} = map}) do
    %{
      activity_type: :manufacturing,
      time: Map.get(map, "time"),
      materials: Enum.map(mats, fn m -> EveIndustrex.Industry.BlueprintActivityMaterial.Mapper.from_dump(m) end),
      products: Enum.map(prods, fn p -> EveIndustrex.Industry.BlueprintActivityProduct.Mapper.from_dump(p) end),
      skills: Enum.map(skills, fn s -> EveIndustrex.Industry.BlueprintActivitySkill.Mapper.from_dump(s) end),
    }
  end
  def from_dump({"manufacturing", %{"materials" => mats, "products" => prods} = map}) do
    %{
      activity_type: :manufacturing,
      time: Map.get(map, "time"),
      materials: Enum.map(mats, fn m -> EveIndustrex.Industry.BlueprintActivityMaterial.Mapper.from_dump(m) end),
      products: Enum.map(prods, fn p -> EveIndustrex.Industry.BlueprintActivityProduct.Mapper.from_dump(p) end),
    }
  end
  def from_dump({"manufacturing", %{"materials" => mats, "skills" => skills} = map}) do

    %{
      activity_type: :manufacturing,
      time: Map.get(map, "time"),
      materials: Enum.map(mats, fn m -> EveIndustrex.Industry.BlueprintActivityMaterial.Mapper.from_dump(m) end),
      skills: Enum.map(skills, fn s -> EveIndustrex.Industry.BlueprintActivitySkill.Mapper.from_dump(s) end),
    }
  end
  def from_dump({"manufacturing", %{} = map}) do
    %{
      activity_type: :manufacturing,
      time: Map.get(map, "time"),
    }
  end
  def from_dump({"research_time", %{} = map}) do
    %{
      activity_type: :research_time,
      time: Map.get(map, "time")
    }
  end
  def from_dump({"research_material", %{} = map}) do
    %{
      activity_type: :research_material,
      time: Map.get(map, "time")
    }
  end
  def from_dump({"invention", %{"products" => prods, "materials" => mats, "skills" => skills} = map}) do

    %{
      activity_type: :invention,
      time: Map.get(map, "time"),
      materials: Enum.map(mats, fn m -> EveIndustrex.Industry.BlueprintActivityMaterial.Mapper.from_dump(m) end),
      products: Enum.map(prods, fn p -> EveIndustrex.Industry.BlueprintActivityProduct.Mapper.from_dump(p) end),
      skills: Enum.map(skills, fn s -> EveIndustrex.Industry.BlueprintActivitySkill.Mapper.from_dump(s) end),
    }
  end
  def from_dump({"invention", %{"skills" => skills, "materials" => mats} = map}) do
    %{
      activity_type: :invention,
      time: Map.get(map, "time"),
      materials: Enum.map(mats, fn m -> EveIndustrex.Industry.BlueprintActivityMaterial.Mapper.from_dump(m) end),
      skills: Enum.map(skills, fn s -> EveIndustrex.Industry.BlueprintActivitySkill.Mapper.from_dump(s) end),

    }
  end
  def from_dump({"invention", %{} = map}) do
    %{
      activity_type: :invention,
      time: Map.get(map, "time")
    }
  end
  def from_dump({"reaction", %{} = map}) do
    %{
      activity_type: :reaction,
      materials: Enum.map(Map.get(map, "materials"), fn m -> EveIndustrex.Industry.BlueprintActivityMaterial.Mapper.from_dump(m) end),
      products: Enum.map(Map.get(map, "products"), fn p -> EveIndustrex.Industry.BlueprintActivityProduct.Mapper.from_dump(p) end),
      skills: Enum.map(Map.get(map, "skills"), fn s -> EveIndustrex.Industry.BlueprintActivitySkill.Mapper.from_dump(s) end),
      time: Map.get(map, "time")
    }
  end
end
