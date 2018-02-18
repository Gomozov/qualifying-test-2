defmodule Extop.Parser do
  require Logger

  @moduledoc """
  Parser works with a List of Strings. 
  """
  
  @doc """
    Parse List of Strings from file README.md. 

    Returns Map with libraries like:

    %{"Folder" => [%H4cc.Lib{desc: "Description 1", name: "Name 1", url: "https://github.com/url1", is_git: true}, %H4cc.Lib{desc: "Description 2", name: "Name 2", url: "https://github.com/url2", is_git: true}, ...]}
  """

  def parse_file(file) do
    file
    |> String.split("\n", trim: true)
    |> fetch_repo(%{})
    |> Enum.map(&prepare_lib/1)
    |> List.flatten()
  end
  
  @doc """
    Takes Map and returns Tuple like: %{Key, [%{name: name, url: url, desc: description},...]}.
  ## Example 
      iex> H4cc.Parser.prepare_lib({"## Folder", ["* [Name 1](URL 1) - Desc 1", "* [Name 2](URL 2) - Desc 2"]})
      {"Folder", [%H4cc.Lib{commited: nil, desc: "Desc 1", folder: "Folder", is_git: false, name: "Name 1", stars: 0, url: "URL 1"}, %H4cc.Lib{commited: nil, desc: "Desc 2", folder: "Folder", is_git: false, name: "Name 2", stars: 0, url: "URL 2"}]}
  """

  def prepare_lib({k, v}) do
    key = String.slice(k, 3..-1)           # Slice "## "
    v
    |> Enum.map(&String.slice(&1, 2..-1))  # Slice "* "
    |> Enum.map(&parse_str(&1, key))
  end
  
  @doc """
    Takes String and returns %H4cc.Lib with name, url, description.
  ## Example 
      iex> H4cc.Parser.parse_str("[Name](https://github.com/url) - Description", "Folder")
      %H4cc.Lib{commited: nil, desc: "Description", folder: "Folder", is_git: true, name: "Name", stars: 0, url: "https://github.com/url"}
  """

  def parse_str(str, key) do
    {str, %Extop.Library{folder: key}}
    |> get_name()
    |> get_url()
    |> get_desc()
    |> check_url()
  end

  @doc """
    Takes tuple {String, %H4cc.Lib{}} and returns tuple {String (without name), %H4cc.Lib{name: name}}.
  ## Example 
      iex> H4cc.Parser.get_name({"[Name](https://github.com/url) - Description", %H4cc.Lib{folder: "Folder"}})
      {"(https://github.com/url) - Description", 
      %H4cc.Lib{commited: nil, desc: nil, folder: "Folder", is_git: false, name: "Name", stars: 0, url: nil}}
  """

  def get_name({str, lib}) do
    name =
    str
    |> (&Regex.run(~r/\[.+?\]/, &1)).()
    |> List.to_string
    {String.trim_leading(str, name), %{lib | name: String.slice(name, 1..-2)}}
  end
  
  @doc """
    Takes tuple {String, %H4cc.Lib{}} and returns tuple {String (without URL), %H4cc.Lib{url: URL}}.
  ## Example 
      iex> H4cc.Parser.get_url({"(https://github.com/url) - Description", %H4cc.Lib{commited: nil, desc: nil, folder: "Folder", is_git: nil, name: "Name", stars: 0, url: nil}})
      {" - Description", %H4cc.Lib{commited: nil, desc: nil, folder: "Folder", is_git: nil, name: "Name", stars: 0, url: "https://github.com/url"}}
  """

  def get_url({str, lib}) do
    url =
    str
    |> (&Regex.run(~r/\(.+?\)/, &1)).()
    |> List.to_string
      {String.trim_leading(str, url), %{lib | url: String.slice(url, 1..-2)}}
  end

  @doc """
    Takes String and returns description of a library
  ## Example 
      iex> H4cc.Parser.get_desc({" - Description", %H4cc.Lib{commited: nil, desc: nil, folder: "Folder", is_git: nil, name: "Name", stars: 0, url: "https://github.com/url"}})
      %H4cc.Lib{commited: nil, desc: "Description", folder: "Folder", is_git: nil, name: "Name", stars: 0, url: "https://github.com/url"}
  """

  def get_desc({str, lib}) do
    %{lib | desc: String.trim_leading(str, " - ")}
  end

  @doc """
    Takes %H4cc.Lib{} and returns true if URL is a github repository.
  ## Example 
      iex> H4cc.Parser.check_url(%H4cc.Lib{commited: nil, desc: "Description", folder: "Folder", is_git: nil, name: "Name", stars: 0, url: "https://github.com/url"})
      %H4cc.Lib{commited: nil, desc: "Description", folder: "Folder", is_git: true, name: "Name", stars: 0, url: "https://github.com/url"}
  """

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
