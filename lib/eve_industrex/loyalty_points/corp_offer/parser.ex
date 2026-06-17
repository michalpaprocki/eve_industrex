defmodule EveIndustrex.LoyaltyPoints.CorpOffer.Parser do


  def apply_expression(offers, expression) do
    case expression do
      {:profit} ->
         Map.new(
             Enum.filter(offers, fn {_id, o} -> is_number(o.isk_on_lp) and o.isk_on_lp > 0 end)
            )
      {:gt, amount} ->
        Map.new(
              Enum.filter(offers, fn {_id, o} -> is_number(o.isk_on_lp) and o.isk_on_lp > amount end)
            )
      {:lt, amount} ->
        Map.new(
            Enum.filter(offers, fn {_id, o} -> is_number(o.isk_on_lp) and o.isk_on_lp < amount end)
            )
      {:range, min, max} ->
          Map.new(
            Enum.filter(offers, fn {_id, o} -> is_number(o.isk_on_lp) and min <= o.isk_on_lp and o.isk_on_lp <= max end)
            )
      _ ->
        offers
    end
  end
  def apply_text_filter(offers, nil), do: offers
  def apply_text_filter(offers, ""), do: offers
  def apply_text_filter(offers, text_filter) do
    case text_filter do
      nil ->
        offers
      _ ->
        Map.new(
          Enum.filter(offers, fn {_id, o} -> String.contains?(String.downcase(o.type.name) , String.downcase(text_filter)) end)
          )
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
