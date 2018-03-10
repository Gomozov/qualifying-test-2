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

  def prepare_lib({k, v}) do
    key = String.slice(k, 3..-1)           # Slice "## "
    v
    |> Enum.map(&String.slice(&1, 2..-1))  # Slice "* "
    |> Enum.map(&parse_str(&1, key))
  end
  
  def parse_str(str, key) do
    {str, %{folder: key, name: "", url: "", desc: "", is_git: false}}
    |> get_name()
    |> get_url()
    |> get_desc()
    |> check_url()
  end

  def get_name({str, lib}) do
    name =
    str
    |> (&Regex.run(~r/\[.+?\]/, &1)).()
    |> List.to_string
    {String.trim_leading(str, name), %{lib | name: String.slice(name, 1..-2)}}
  end
  
  def get_url({str, lib}) do
    url =
    str
    |> (&Regex.run(~r/\(.+?\)/, &1)).()
    |> List.to_string
      {String.trim_leading(str, url), %{lib | url: String.slice(url, 1..-2)}}
  end

  def get_desc({str, lib}) do
    %{lib | desc: String.trim_leading(str, " - ")}
  end

  def check_url(lib) do
    if String.contains?(lib.url, "https://github.com/") do
      %{lib | is_git: true}
    else
      %{lib | is_git: false}
    end  
  end

  def fetch_repo([_head | []], acc) do
    cond do
      true                            -> acc
    end
  end
  
  def fetch_repo([head | tail], acc) do
    cond do
      String.starts_with?(head, "##") -> fetch_repo(tail, Map.merge(acc, Map.new([{head, []}])), head)
      true                            -> fetch_repo(tail, acc)
    end
  end

  def fetch_repo([head | []], acc, key) do
    cond do
      String.starts_with?(head, "* ") -> Map.update!(acc, key, &Enum.concat(&1, [head]))
      true                            -> acc
    end
  end
  
  def fetch_repo([head | tail], acc, key) do
    cond do
      String.starts_with?(head, "##") -> fetch_repo(tail, Map.merge(acc, Map.new([{head, []}])), head)
      String.starts_with?(head, "* ") -> fetch_repo(tail, Map.update!(acc, key, &Enum.concat(&1, [head])), key)
      true                            -> fetch_repo(tail, acc, key)
    end
  end
end
