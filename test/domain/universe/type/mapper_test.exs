defmodule Domain.Universe.Type.MapperTest do
  use ExUnit.Case
  alias EveIndustrex.Universe.Type.Mapper

  setup_all  do
    mock_dump_types = [
    %{
      "_key" => 223,
      "basePrice" => 800.0,
      "description" => %{
        "de" => "Besteht aus zwei Komponenten: Einem Mantel aus Titanium und einem Kern aus Eisenatomen, die in einem Plasmastatus außer Kraft gesetzt sind. Railguns schießen den Mantel direkt hinaus, während Partikelblaster das Plasma in einen Zyklotron pumpen und es dann zu einem Bolzen verarbeiten, der abgefeuert wird.\n\n60% höhere optimale Reichweite.\n30% niedrigerer Energiespeicherbedarf.",
        "en" => "Consists of two components: a shell of titanium and a core of iron atoms suspended in a plasma state. Railguns launch the shell directly, while particle blasters pump the plasma into a cyclotron and process the plasma into a bolt that is then fired.\n\n60% increased optimal range.\n30% reduced capacitor need.",
        "es" => "Consta de dos componentes: un proyectil de titanio y un núcleo de átomos de hierro suspendidos en estado plasmático. Los cañones electromagnéticos lanzan el proyectil directamente al tiempo que los blásteres de partículas bombean el plasma a un ciclotrón y lo transforman en un rayo que luego se dispara.\n\nAlcance óptimo aumentado un 60\u00A0%.\nNecesidad del condensador reducida un 30\u00A0%.",
        "fr" => "Concentre deux composants\u00A0:\u00A0une coque en titane et un noyau d'atomes de fer stabilisés à l'état plasma. Les canons à rail éjectent directement l'obus, tandis que les blasters à particules injectent le plasma dans un cyclotron, où la matière est condensée avant d'être libérée.\n\nAugmente de 60\u00A0%\u00A0la portée optimale.\nRéduit de 30\u00A0%\u00A0les besoins énergétiques du capaciteur.",
        "ja" => "チタン製のシェル、プラズマ状態に保たれた鉄原子のコアという2つのコンポーネントから成る。シェルごと発射して攻撃するレールガンに対し、粒子ブラスターは一度プラズマをサイクロトロン加速器に送り込み、発生した稲妻により攻撃する。最適射程距離が60%拡大。キャパシタの使用量が30%削減。",
        "ko" => "티타늄으로 코팅된 탄두 속에 철 분자가 플라즈마 상태로 저장되어 있습니다. 레일건을 격발하는 순간 입자 블라스터는 플라즈마를 사이클로트론에 주입하고 투사체로 변환시켜 발사합니다. <br><br>최적사거리 60% 증가 <br>캐패시터 사용량 30% 감소",
        "ru" => "Состоит из двух компонентов: титанового корпуса плазменной ловушки и сердечника из атомов железа в состоянии плазмы. При стрельбе боеприпасом из рельсотронов по цели выстреливается весь снаряд целиком, при стрельбе из бластеров — лишь сгусток плазмы, закачиваемой из ловушки в циклотрон бластера.\n\nНа 60% повышается оптимальная дальность ведения огня.\nНа 30% снижается потребление энергии накопителя.",
        "zh" => "由两部分组成：钛金制的弹壳和离子态的铁原子芯核。磁轨炮直接射出弹壳，而粒子疾速炮将等离子注入回旋加速器中，然后将等离子如闪电般发射出去。 \n\n最佳射程提升60%。\n电容需求降低30%。"
      },
      "graphicID" => 1319,
      "groupID" => 85,
      "iconID" => 1319,
      "marketGroupID" => 108,
      "mass" => 0.05,
      "metaGroupID" => 1,
      "name" => %{
        "de" => "Iron Charge M",
        "en" => "Iron Charge M",
        "es" => "Carga de hierro (M)",
        "fr" => "Charge de fer M",
        "ja" => "アイアン弾M",
        "ko" => "강철탄 M",
        "ru" => "Iron Charge M",
        "zh" => "铁质轨道弹 M"
      },
      "portionSize" => 100,
      "published" => true,
      "volume" => 0.0125
    },
    %{
      "_key" => 224,
      "basePrice" => 1100.0,
      "description" => %{
        "de" => "Besteht aus zwei Komponenten: Einer Granate aus Titan und einem Kern aus Tungsten-Atomen im Plasmazustand. Railguns verschießen die Granate direkt, während Partikelblaster das Plasma in ein Zyklotron pumpen und dann zu einem Geschoss formen, das abgefeuert wird.\n\n\n\n40% höhere optimale Reichweite.\n\n27% niedrigerer Energiespeicherverbrauch.",
        "en" => "Consists of two components: a shell of titanium and a core of tungsten atoms suspended in plasma state. Railguns launch the shell directly, while particle blasters pump the plasma into a cyclotron and process the plasma into a bolt that is then fired.\n\n40% increased optimal range.\n27% reduced capacitor need.",
        "es" => "Consta de dos componentes: un proyectil de titanio y un núcleo de átomos de tungsteno suspendidos en estado plasmático. Los cañones electromagnéticos lanzan el proyectil directamente al tiempo que los blásteres de partículas bombean el plasma a un ciclotrón y lo transforman en un rayo que luego se dispara.\n\nAlcance óptimo aumentado un 40\u00A0%.\n\nNecesidad del condensador reducida un 27\u00A0%.",
        "fr" => "Il contient deux composants : une coque en titane et un noyau d'atomes de tungstène conservés sous un état plasma. Des canons à rail éjectent directement l'obus tandis que des blasters à particules injectent le plasma dans un cyclotron pour former un éclair qui est ensuite tiré sur la cible.\n\nAugmente de 40 % la portée optimale.\nRéduit de 27 % les besoins énergétiques du capaciteur.",
        "ja" => "構成部品は2つしかない。チタンの弾殻と、プラズマ状態で封じ込められたタングステン原子のコアだ。レールガンが弾殻を物理的に射出するのに対し、粒子ブラスターはプラズマをサイクロトロンに送り込み、いわば光の矢に変えて発射する。最適射程距離が40％延長。キャパシタ使用量が27%低減。",
        "ko" => "티타늄으로 코팅된 탄두 속에 텅스텐 분자가 플라즈마 상태로 저장되어 있습니다. 레일건을 격발하는 순간 입자 블라스터는 플라즈마를 사이클로트론에 주입하고 투사체로 변환시켜 발사합니다. <br><br>최적사거리 40% 증가 <br>캐패시터 사용량 27% 감소",
        "ru" => "Представляет собой плазменную ловушку, заключённую в титановый корпус; внутри ловушки находится плазма из атомов вольфрама. При стрельбе боеприпасом из рейлганов по цели выстреливается весь снаряд целиком, при стрельбе из бластеров — лишь сгусток плазмы, закачиваемой из ловушки в циклотрон бластера.\n\n\n\nПовышает оптимальную дальность действия на 40%.\n\nСнижает потребление энергии конденсатора на 27%.",
        "zh" => "由两部分组成：钛金制的弹壳和离子态的钨原子芯核。磁轨炮直接射出弹壳，而粒子疾速炮将等离子注入回旋加速器中，然后将等离子如闪电般发射出去。最佳射程提升40%。电容需求降低27%。"
      },
      "graphicID" => 1323,
      "groupID" => 85,
      "iconID" => 1323,
      "marketGroupID" => 108,
      "mass" => 0.05,
      "metaGroupID" => 1,
      "name" => %{
        "de" => "Tungsten Charge M",
        "en" => "Tungsten Charge M",
        "es" => "Carga de tungsteno (M)",
        "fr" => "Charge de tungstène M",
        "ja" => "タングステン弾M",
        "ko" => "텅스텐탄 M",
        "ru" => "Tungsten Charge M",
        "zh" => "钨质轨道弹 M"
      },
      "portionSize" => 100,
      "published" => true,
      "volume" => 0.0125
    }
  ]
    mock_esi_types = [
     %{
  capacity: 0,
  description: "Consists of two components: a shell of titanium and a core of iron atoms suspended in a plasma state. Railguns launch the shell directly, while particle blasters pump the plasma into a cyclotron and process the plasma into a bolt that is then fired.\r\n\r\n60% increased optimal range.\r\n30% reduced capacitor need.",
  dogma_attributes: [
    %{
        attribute_id: 128,
        value: 2
      },
      %{
        attribute_id: 161,
        value: 0.0125
      },
      %{
        attribute_id: 162,
        value: 1
      },
      %{
        attribute_id: 4,
        value: 0.05
      },
      %{
        attribute_id: 38,
        value: 0
      },
      %{
        attribute_id: 422,
        value: 1
      },
      %{
        attribute_id: 137,
        value: 74
      },
      %{
        attribute_id: 779,
        value: 1.6
      },
      %{
        attribute_id: 114,
        value: 0
      },
      %{
        attribute_id: 116,
        value: 0
      },
      %{
        attribute_id: 117,
        value: 6
      },
      %{
        attribute_id: 118,
        value: 4
      },
      %{
        attribute_id: 120,
        value: 1.6
      },
      %{
        attribute_id: 124,
        value: 5202838
      },
      %{
        attribute_id: 317,
        value: -30
      },
  ],
  dogma_effects: [
    %{
      effect_id: 596,
      is_default: false
    },
    %{
      effect_id: 804,
      is_default: false
    }
  ],
  graphic_id: 1319,
  group_id: 85,
  icon_id: 1319,
  market_group_id: 108,
  mass: 0.05,
  name: "Iron Charge M",
  packaged_volume: 0.0125,
  portion_size: 100,
  published: true,
  radius: 1,
  type_id: 223,
  volume: 0.0125
},
  %{
    capacity: 0,
    description: "Consists of two components: a shell of titanium and a core of tungsten atoms suspended in plasma state. Railguns launch the shell directly, while particle blasters pump the plasma into a cyclotron and process the plasma into a bolt that is then fired.\r\n\r\n40% increased optimal range.\r\n27% reduced capacitor need.",
    dogma_attributes: [
     %{
        attribute_id: 128,
        value: 2
      },
     %{
        attribute_id: 161,
        value: 0.0125
      },
     %{
        attribute_id: 162,
        value: 1
      },
     %{
        attribute_id: 4,
        value: 0.05
      },
     %{
        attribute_id: 38,
        value: 0
      },
     %{
        attribute_id: 422,
        value: 1
      },
     %{
        attribute_id: 137,
        value: 74
      },
     %{
        attribute_id: 779,
        value: 1.4
      },
     %{
        attribute_id: 114,
        value: 0
      },
     %{
        attribute_id: 116,
        value: 0
      },
     %{
        attribute_id: 117,
        value: 8
      },
     %{
        attribute_id: 118,
        value: 4
      },
     %{
        attribute_id: 120,
        value: 1.4
      },
     %{
        attribute_id: 124,
        value: 5801883
      },
     %{
        attribute_id: 317,
        value: -27
      }
    ],
    dogma_effects: [
     %{
        effect_id: 596,
        is_default: false
      },
     %{
        effect_id: 804,
        is_default: false
      }
    ],
    graphic_id: 1323,
    group_id: 85,
    icon_id: 1323,
    market_group_id: 108,
    mass: 0.05,
    name: "Tungsten Charge M",
    packaged_volume: 0.0125,
    portion_size: 100,
    published: true,
    radius: 1,
    type_id: 224,
    volume: 0.0125
  }
    ]
    {:ok, %{:dump => mock_dump_types, :esi => mock_esi_types}}
  end

  test "Converts jsonl entries into unified maps", context do
    dump = context.dump
    maps = Enum.map(dump, fn d -> Mapper.from_dump(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :type_id) && Map.has_key?(m, :name) && Map.has_key?(m, :capacity) && Map.has_key?(m, :description) && Map.has_key?(m, :icon_id) && Map.has_key?(m, :mass) && Map.has_key?(m, :packaged_volume) && Map.has_key?(m, :portion_size) && Map.has_key?(m, :published) && Map.has_key?(m, :radius) && Map.has_key?(m, :market_group_id) && Map.has_key?(m, :group_id) && Map.has_key?(m, :volume) end), "Every map in the list has :type_id, :name, :capacity, :icon_id, :mass, :packaged_volume, :published, :portion_size, :radius, :group_id, :volume, :market_group_id and :description")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end

  test "Converts esi response into unified maps", context do
    data = context.esi
    maps = Enum.map(data, fn d -> Mapper.from_esi(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :type_id) && Map.has_key?(m, :name) && Map.has_key?(m, :capacity) && Map.has_key?(m, :description) && Map.has_key?(m, :icon_id) && Map.has_key?(m, :mass) && Map.has_key?(m, :packaged_volume) && Map.has_key?(m, :portion_size) && Map.has_key?(m, :published) && Map.has_key?(m, :radius) && Map.has_key?(m, :market_group_id) && Map.has_key?(m, :group_id) && Map.has_key?(m, :volume) end), "Every map in the list has :type_id, :name, :capacity, :icon_id, :mass, :packaged_volume, :published, :portion_size, :radius, :group_id, :volume, :market_group_id and :description")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
end
