defmodule EveIndustrex.LiveParser do
  def apply_expression(collection, key, expression) do
    case expression do
      {:profit} ->
        Map.new(Enum.filter(collection, fn {_id, o} -> is_number(o[key]) and o[key] > 0 end))

      {:gt, amount} ->
        Map.new(Enum.filter(collection, fn {_id, o} -> is_number(o[key]) and o[key] > amount end))

      {:lt, amount} ->
        Map.new(Enum.filter(collection, fn {_id, o} -> is_number(o[key]) and o[key] < amount end))

      {:range, min, max} ->
        Map.new(
          Enum.filter(collection, fn {_id, o} ->
            is_number(o[key]) and min <= o[key] and o[key] <= max
          end)
        )

      _ ->
        collection
    end
  end

  def apply_text_filter(collection, nil), do: collection
  def apply_text_filter(collection, ""), do: collection

  def apply_text_filter(collection, text_filter) do
    case text_filter do
      nil ->
        collection

      _ ->
        group_filter =
          Enum.filter(collection, fn {_id, o} ->
            String.contains?(String.downcase(o.type.group), String.downcase(text_filter))
          end)

        if length(group_filter) == 0 do
          Map.new(
            Enum.filter(collection, fn {_id, o} ->
              String.contains?(String.downcase(o.type.name), String.downcase(text_filter))
            end)
          )
        else
          Map.new(group_filter)
        end
    end
  end

  def parse_filter(nil) do
    %{expression: nil, text_filter: nil}
  end

  def parse_filter("") do
    %{expression: nil, text_filter: nil}
  end

  def parse_filter(string) do
    case String.split(string, ":", parts: 2) do
      [filter] ->
        build_filter(String.downcase(String.trim(filter)), nil)

      [expr, filter] ->
        build_filter(expr, String.downcase(String.trim(filter)))
    end
  end

  def maybe_compose_query(filter, sorter) do
    cond do
      sorter != "" and filter == "++" ->
        "?sort=#{sorter}&query=profit"

      sorter != "" and filter != nil and filter != "" ->
        "?sort=#{sorter}&query=#{URI.encode_www_form(String.trim(filter))}"

      true ->
        "?sort=#{sorter}"
    end
  end

  defp parse_expression("++"), do: {:profit}

  defp parse_expression(">" <> rest) do
    case Integer.parse(rest) do
      {n, ""} ->
        {:gt, n}

      _ ->
        nil
    end
  end

  defp parse_expression("<" <> rest) do
    case Integer.parse(rest) do
      {n, ""} ->
        {:lt, n}

      _ ->
        nil
    end
  end

  defp parse_expression(expr) do
    case Regex.run(~r/^\[(\d+)\.\.(\d+)\]$/, expr) do
      [_, min, max] ->
        {:range, String.to_integer(min), String.to_integer(max)}

      _ ->
        nil
    end
  end

  defp build_filter(<<"[", _::binary>> = expr, text_filter) do
    %{expression: parse_expression(expr), text_filter: text_filter}
  end

  defp build_filter(<<">", _::binary>> = expr, text_filter) do
    %{expression: parse_expression(expr), text_filter: text_filter}
  end

  defp build_filter(<<"<", _::binary>> = expr, text_filter) do
    %{expression: parse_expression(expr), text_filter: text_filter}
  end

  defp build_filter(<<"+", _::binary>> = expr, text_filter) do
    %{expression: parse_expression(expr), text_filter: text_filter}
  end

  defp build_filter(text_filter, nil) do
    %{expression: nil, text_filter: text_filter}
  end

  defp build_filter(_expr, text_filter) do
    %{expression: nil, text_filter: text_filter}
  end
end
