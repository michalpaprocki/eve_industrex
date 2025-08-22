defmodule EveIndustrex.Logger.EiLogger do
  @moduledoc """
  Logger for the App
  """
  require Logger
  @types_list [:error]
  @err_path "/logs/error_log.txt"

  @spec log(atom(), {atom(), binary(), binary()}):: :ok

  @doc """
    Logs message to log file.

    Returns `:ok`
    ## Examples

      iex: EiLogger.log(:error, {:err_responded_with, "400", https://example.com})

  """
  def log(type, msg) when type in @types_list and is_atom(type) and is_tuple(msg) do

    path =
    case type do
      :error ->
        @err_path
    end
      maybe_create_log_file(log_file_present?(path))
      write_to_file(type, path, msg)
    :ok
  end

  def log(type, _msg) do
    fun = Function.info(&log/2)
    Logger.error(%ArgumentError{
    message: "#{Keyword.get(fun, :module)}, :#{Keyword.get(fun, :name)}, #{Keyword.get(fun, :arity)} received #{type} as an argument, allowed args are: [#{Enum.map(@types_list, fn tl -> "\:"<>Atom.to_string(tl) end)}]."
  })
  end
  defp write_to_file(type, path, {status, reason, source}) do
    msg = Atom.to_string(type)<>": "<>Atom.to_string(status)<>": "<>reason<>" | "<>source
    case type do
      :error ->
        Logger.error(msg)
        :noop
    end
    msg_with_date = DateTime.to_string(DateTime.utc_now())<>": "<>msg
    log_file =
      File.read!(Path.join(File.cwd!(), path))
      |> String.split("\n")
      |> Enum.filter(fn x -> x != "" end)


    new_log_file = [String.trim(msg_with_date), log_file]  |> List.flatten() |> Enum.map(fn x -> x<>"\n" end)

    File.write!(Path.join(File.cwd!(), path), new_log_file)
  end
  defp log_file_present?(path) do
    {File.exists?(Path.join(File.cwd!(), path)), path}
  end
  defp maybe_create_log_file({true, _path}), do: :noop
  defp maybe_create_log_file({false, path}) do
    File.touch(Path.join(File.cwd!(), path))
  end

end
