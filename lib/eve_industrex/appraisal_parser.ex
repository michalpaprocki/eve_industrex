defmodule EveIndustrex.AppraisalParser do


  def parse(list) do
    split_list =
      list
      |> String.trim()
      |> String.split(~r/\n/)

    case select_parser(hd(split_list)) do

      :eft ->
        eft_parser(split_list)

      _-> :ok
    end
  end

  defp select_parser(line) do
    cond do
      Regex.match?(~r/(?=\[).+(?<=\])/, line) ->
        :eft

      true ->
          :ok
    end
  end

  defp eft_parser(list) do
      list
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.frequencies()
      |> Enum.map(fn {k,v} -> extract_amounts(k,v) end)
      |> Enum.map(fn {k,v} -> remove_empty(k,v) end)
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.map(fn {k,v} -> extract_ship(k,v) end)
      |> Enum.reverse()
  end

  defp extract_amounts(k, v) do
    if Regex.match?(~r/x(?=[0-9])\d+| \d+/, k) do

      key =
        hd(Regex.run(~r/.+?(?=x[0-9]| [0-9])/, k))
        |> String.trim()
      {key, v}
    else
      {k,v}
    end
  end

  defp remove_empty(k, v) do
    case Regex.run(~r/(?=\[).*(?<=\])/, k) do
      nil ->
        {k,v}
      string ->
        if String.contains?(hd(string), "mpty") do
          nil
        else
          {hd(String.split(hd(Regex.run(~r/(?<=\[).+?(?=\])/, hd(string))), ",")), 1}
        end
    end
  end

  defp extract_ship(k, v) do
    if Regex.run(~r/(?=\[).*(?<=\])/, k) do
      {String.split(k, ","), 1}
    else
      {k,v}
    end
  end

end
