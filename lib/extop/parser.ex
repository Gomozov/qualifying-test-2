defmodule Extop.Parser do
  require Logger

  @moduledoc """
  Parses file to %Extop.Library structure. 
  """

  def parse_file(file) do
    file
    |> String.split("\n", trim: true)
    |> fetch_repo(%{})
    |> Enum.map(&prepare_lib/1)
    |> List.flatten()
  end

  defp prepare_lib({k, v}) do
    key = String.slice(k, 3..-1)           # Slice "## "
    Enum.map(v, &parse_str(&1, key))
  end
  
  defp parse_str(str, key) do
    %{folder: key, name: "", url: "", desc: "", is_git: false}
    |> get_line(str)
    |> check_url()
  end

  defp get_line(lib, str) do
    regex = ~r/^(\*\s)\[([^]]+)\]\(([^)]+)\) - (.+)([\.\!]+)$/
    case Regex.run(regex, str) do
      nil -> 
        Logger.warn "Line doesn't match: '#{str}'"
        lib
      [^str, _star, name, url, desc, _dot] -> %{lib | name: name, url: url, desc: desc}
    end
  end

  defp check_url(lib) do
    if String.contains?(lib.url, "https://github.com/"), 
      do:   %{lib | is_git: true},
      else: %{lib | is_git: false}
  end

  defp fetch_repo([_head | []], acc), do: acc
  
  defp fetch_repo([head | tail], acc) do
    cond do
      String.starts_with?(head, "##") -> fetch_repo(tail, Map.merge(acc, %{head => []}), head)
      true                            -> fetch_repo(tail, acc)
    end
  end

  defp fetch_repo([head | []], acc, key) do
    cond do
      String.starts_with?(head, "* ") -> Map.update!(acc, key, &(&1++[head]))
      true                            -> acc
    end
  end
  
  defp fetch_repo([head | tail], acc, key) do
    cond do
      String.starts_with?(head, "##") -> fetch_repo(tail, Map.merge(acc, %{head => []}), head)
      String.starts_with?(head, "* ") -> fetch_repo(tail, Map.update!(acc, key, &(&1++[head])), key)
      true                            -> fetch_repo(tail, acc, key)
    end
  end
end
