defmodule EveIndustrex.Utils do

  def get_pages_ammount(url) when is_binary(url) do
    request = Req.Request.new(url: url, method: :head)
    {_req, res} = Req.run(request)
    case res do
      %Req.Response{status: 200, body: _body, headers:
        %{"x-pages" => pages},
        private: _private, trailers: _trailers} ->
        {:ok, pages}

      %Req.Response{status: 200, body: _body, headers: _headers,
        private: _private, trailers: _trailers} ->
       {:ok, nil}
      %Req.Response{status: status, body: body, headers: _headers,
        private: _private, trailers: _trailers} ->
        {:error, {status, body}}
      _->
        nil
    end
  end

  def get_chunked_list(list, chunk), do: Enum.chunk_every(list, chunk)

  def fetch_from_url(url) do

    case Req.get(url: url) do
      {:error, _} ->
        raise "Could not fetch from provided url: #{inspect(url)}"
      {:ok, %Req.Response{:status=> 200} = response} ->
          response.body
      {:ok, %Req.Response{:status=> _}} = _response ->

        raise "Could not fetch from provided url: #{inspect(url)}"
    end
  end
  def fetch_from_url(url, _index) do

    case Req.get(url: url) do
      {:error, _} ->
        raise "Could not fetch from provided url: #{inspect(url)}"
      {:ok, %Req.Response{:status=> 200} = response} ->
          response.body
      {:ok, %Req.Response{:status=> _}} = _response ->
        raise "Could not fetch from provided url: #{inspect(url)}"
    end
  end
  def calculate_time_difference(%DateTime{} = time) do
    {:ok, now} = DateTime.now("Etc/UTC")
    diff = DateTime.diff(now, time)
    format_time(diff)
  end

  defp format_time(time) do
    cond do

      time > 60 * 60 * 24 * 30 ->
        if floor(time / (3600 * 24 * 30)) == 1,
          do: "1 month ago",
          else: Integer.to_string(floor(time / (3600 * 24 * 30))) <> " months ago"

      time > 60 * 60 * 24 ->
        if floor(time / (3600 * 24)) == 1,
          do: "1 day ago",
          else: Integer.to_string(floor(time / (3600 * 24))) <> " days ago"

      time > 60 * 60 ->
        if floor(time / 3600) == 1,
          do: "1 hour ago",
          else: Integer.to_string(floor(time / 3600)) <> " hours ago"

      time > 60 ->
        if floor(time / 60) == 1,
          do: "1 minute ago",
          else: Integer.to_string(floor(time / 60)) <> " minutes ago"

      time ->
        "less than a minute ago"
    end
  end

  def get_time_left(date, duration) do
        {:ok, new_date, _offset} = DateTime.from_iso8601(date)
        ends = DateTime.add(new_date, duration, :day)
        now = DateTime.now!("Etc/UTC")
        format_time_left(DateTime.diff(ends, now, :second))
  end
  defp format_time_left(time) do
    days = div(div(div(time, 60), 60), 24)
    hours = floor(((time - days * 60 * 60 * 24) / (60 * 60)))
    minutes = floor(rem((time - days * 60 * 60 * 24), (60 * 60)) / 60)
    ~s"#{days}d #{hours}h #{minutes}m"
  end

  def format_with_coma(price_float) when is_float(price_float) do
  price = :erlang.float_to_binary(price_float, [decimals: 2])
  reversed_string = String.reverse(price)
  pre_with_comas = Enum.map(Enum.with_index(String.to_charlist(reversed_string)), fn {s, index} -> if index > 3 && rem(index + 1, 3) == 0 && index != String.length(reversed_string) - 1, do: [s,","], else: s end)
  with_comas = String.reverse(List.to_string(List.flatten(pre_with_comas)))
  if String.at(with_comas, 0) == "-" && String.at(with_comas, 1) == "," do
    tail = elem(String.split_at(with_comas, 2), 1)
    "-"<>tail
  else
    with_comas
  end
  end
  def format_with_coma(price_integer) when is_integer(price_integer) do
  reversed_string = String.reverse(Integer.to_string(price_integer))
  pre_with_comas = Enum.map(Enum.with_index(String.to_charlist(reversed_string)), fn {s, index} -> if rem(index + 1, 3) == 0 && index != String.length(reversed_string) - 1, do: [s,","], else: s end)
  with_comas = String.reverse(List.to_string(List.flatten(pre_with_comas)))
  if String.at(with_comas, 0) == "-" && String.at(with_comas, 1) == "," do
   tail = elem(String.split_at(with_comas, 2), 1)
    "-"<>tail
  else
    with_comas
  end

  end

  def apply_color_on_status(sec_status) do
    case sec_status do
      "1.0" ->
        "text-system1.0"
      "0.9" ->
        "text-system0.9"
      "0.8" ->
        "text-system0.8"
      "0.7" ->
        "text-system0.7"
      "0.6" ->
        "text-system0.6"
      "0.5" ->
        "text-system0.5"
      "0.4" ->
        "text-system0.4"
      "0.3" ->
        "text-system0.3"
      "0.2" ->
        "text-system0.2"
      "0.1" ->
        "text-system0.1"
      _ ->
        "text-system0.0"
    end
  end
end
