defmodule Extop.LibraryTest do
  use Extop.ModelCase, async: true 
  import Extop.TestHelpers
  alias Extop.Library

  @valid_attrs %{name: "Library", url: "https://url.com", 
                 desc: "Description", folder: "Test", is_git: false}

  setup context do
    if context[:key] do
      first_lib  = 
        insert_library(name: "First library", stars: 5, folder: "Test 1")
      second_lib = 
        insert_library(name: "Second library", stars: nil, folder: "Test 2")
      third_lib  = 
        insert_library(name: "Third library", stars: 10, folder: "Test 3")
      {:ok, one: first_lib, two: second_lib, three: third_lib}
    else
      :ok
    end  
  end

  test "parse_for_md function witn `code`" do
    desc = "Elixir library extending `Enum.min_by/2`, `Enum.max_by/2` and `Enum.min_max_by/2` to return a list of results instead of just one."
    parsed_desc = Library.parse_for_md(desc)
    refute String.contains?(parsed_desc, "`")
    assert String.contains?(parsed_desc, "<code>")
  end 

  test "parse_for_md function without markdown" do
    desc = "Interface for HTTP webservers, frameworks and clients."
    assert Library.parse_for_md(desc) == desc
  end

  test "parse_for_md function with one link" do
    desc = "Spell is a [Web Application Messaging Protocol](http://wamp-proto.org/) (WAMP) client implementation in Elixir."
    parsed_desc = Library.parse_for_md(desc)
    refute String.contains?(parsed_desc, "[")
    assert String.contains?(parsed_desc, "href")
  end

  test "parse_for_md function with several links" do
    desc = "An Elixir library for parsing, constructing, and wildcard-matching URLs. Also available for [Ruby](https://github.com/gamache/fuzzyurl.rb) and [JavaScript](https://github.com/gamache/fuzzyurl.js)."
    parsed_desc = Library.parse_for_md(desc)
    refute String.contains?(parsed_desc, "[")
  end

  test "save_libraries with all valid libs" do
    libs = [%{name: "Name1", url: "URL1", desc: "Desc1", is_git: false, folder: "Folder"},
            %{name: "Name2", url: "URL2", desc: "Desc2", is_git: false, folder: "Folder"}]
    Library.save_libraries(libs)
    assert length(Extop.Repo.all(Extop.Library)) == 2  
  end

  test "save_libraries with one invalid lib" do
    libs = [%{name: "Name1", url: "URL1", desc: "Desc1", is_git: false, folder: "Folder"},
            %{url: "URL2", desc: "Desc2", is_git: false, folder: "Folder"}]
    Library.save_libraries(libs)
    assert length(Extop.Repo.all(Extop.Library)) == 1 
  end

  test "insert_changeset with valid attributes" do 
    changeset = Library.insert_changeset(%Library{}, @valid_attrs)
    assert changeset.valid?
  end

  test "insert_changeset with invalid attributes" do 
    changeset = Library.insert_changeset(%Library{}, %{})
    refute changeset.valid?
  end

  test "changeset with valid attributes" do 
    changeset = Library.changeset(%Library{}, %{stars: 5, commited: "date"})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do 
    changeset = Library.changeset(%Library{}, %{})
    refute changeset.valid?
  end

  test "days_passed function with correct data" do 
    yesterday = Timex.shift(Timex.now, days: -1)
    iso_yesterday = Timex.format!(yesterday, "{ISO:Extended}")
    assert Library.days_passed(iso_yesterday) == 1
  end

  test "days_passed function with uncorrect data" do
    assert Library.days_passed("Error") == nil
  end

  @tag :key
  test "get_libraries with correct min_stars" do
    libs = Library.get_libraries("5")  
    assert Map.has_key?(libs, "Test 1") 
    assert Map.has_key?(libs, "Test 3") 
    refute Map.has_key?(libs, "Test 2") 
  end

  @tag :key
  test "get_libraries with uncorrect min_stars" do
    libs = Library.get_libraries("error")  
    assert Map.has_key?(libs, "Test 1") 
    assert Map.has_key?(libs, "Test 3") 
    assert Map.has_key?(libs, "Test 2") 
  end
end
