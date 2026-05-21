defmodule Domain.Market.MarketGroup.MapperTest do
  use ExUnit.Case
  alias EveIndustrex.Market.MarketGroup.Mapper
  setup_all  do
    mock_dump_market_groups = [
      %{
        "_key" => 4,
        "description" => %{
          "de" => "Raumschiffe aller Größen und Funktionen für Kapselpiloten. Dazu gehören fortschrittliche und Fraktionsvarianten von vielen Rumpftypen.",
          "en" => "Capsuleer spaceships of all sizes and roles, including advanced and faction variants of many hull types",
          "es" => "Pilota naves para capsulistas de todos los tamaños y funciones, incluidos modelos faccionarios avanzados de muchos tipos de casco.",
          "fr" => "Vaisseaux spatiaux de capsulier de tout rôle et de toute taille, y compris les variantes avancées et spécifiques à certaines factions avec plusieurs types de coques",
          "ja" => "カプセラの宇宙船の全サイズおよび機能（性能別、各勢力仕様別船体タイプなど）",
          "ko" => "캡슐리어가 탑승할 수 있는 모든 종류의 함선입니다. (상급 및 팩션 함선 포함)",
          "ru" => "Капсулёрские корабли всех назначений, классов, типов и размеров, включая корабли усовершенствованных проектов и корабли из арсеналов сверхдержав и независимых организаций",
          "zh" => "各种型号和用途的太空飞船，涵盖了高级和势力衍生型号"
        },
        "hasTypes" => false,
        "iconID" => 1443,
        "name" => %{
          "de" => "Schiffe",
          "en" => "Ships",
          "es" => "Naves",
          "fr" => "Vaisseaux",
          "ja" => "艦船",
          "ko" => "함선",
          "ru" => "Корабли",
          "zh" => "舰船"
        }
      },
      %{
        "_key" => 5,
        "description" => %{
          "de" => "Kleine, schnelle Schiffe mit vielseitigen Verwendungszwecken.",
          "en" => "Small, fast vessels suited to a variety of purposes.",
          "es" => "Naves pequeñas y rápidas adecuadas para varios fines.",
          "fr" => "Petits vaisseaux rapides pouvant accomplir diverses tâches.",
          "ja" => "幅広い任務に適した小型高速艦船。",
          "ko" => "작지만 빠른 기체들로 다양한 임무를 수행할 수 있습니다.",
          "ru" => "Это малые быстрые корабли, хорошо подходящие для самых разных задач.",
          "zh" => "护卫舰能满足多种需求和目的。"
        },
        "hasTypes" => false,
        "iconID" => 1443,
        "name" => %{
          "de" => "Standardfregatten",
          "en" => "Standard Frigates",
          "es" => "Fragatas estándar",
          "fr" => "Frégates standards",
          "ja" => "標準型フリゲート",
          "ko" => "일반 프리깃",
          "ru" => "Типовые",
          "zh" => "标准护卫舰"
        },
        "parentGroupID" => 1361
      }
    ]
    mock_esi_market_groups = [
      %{
        description: "desc_test",
        market_group_id: 1,
        name: "name_test",

        types: [

        ]
      },
    %{
        description: "desct_test",
        market_group_id: 12,
        name: "name_test",
        parent_group_id: 1,
        types: [
          53,7,55
        ]
      },
    ]
    {:ok, %{:dump => mock_dump_market_groups, :esi => mock_esi_market_groups}}
  end
  test "Converts jsonl entries into unified maps", context do
    dump = context.dump
    maps = Enum.map(dump, fn d -> Mapper.from_dump(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :market_group_id) && Map.has_key?(m, :description) && Map.has_key?(m, :name) end), "Every map in the list has :market_group_id, :name and :description")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end

  test "Converts esi response into unified maps", context do
    data = context.esi
    maps = Enum.map(data, fn d -> Mapper.from_esi(d) end)
    assert(Enum.each(maps, fn m ->  Map.has_key?(m, :market_group_id) && Map.has_key?(m, :description) && Map.has_key?(m, :name) end), "Every map in the list has :market_group_id, :name and :description")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
end
