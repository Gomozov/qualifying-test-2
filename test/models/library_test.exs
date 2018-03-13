defmodule Extop.LibraryTest do
  use Extop.ModelCase, async: true 
  import Extop.TestHelpers
  alias Extop.Library

  @valid_attrs %{name: "Library", url: "https://url.com", 
                 desc: "Description", folder: "Test", is_git: false}

  setup do
    first_lib  = insert_library(name: "First library", stars: 5, folder: "Test 1")
    second_lib = insert_library(name: "Second library", stars: nil, folder: "Test 2")
    third_lib  = insert_library(name: "Third library", stars: 10, folder: "Test 3")
    {:ok, one: first_lib, two: second_lib, three: third_lib}
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

  test "get_libraries with correct min_stars" do
    libs = Library.get_libraries("5")  
    assert Map.has_key?(libs, "Test 1") 
    assert Map.has_key?(libs, "Test 3") 
    refute Map.has_key?(libs, "Test 2") 
  end

  test "get_libraries with uncorrect min_stars" do
    libs = Library.get_libraries("error")  
    assert Map.has_key?(libs, "Test 1") 
    assert Map.has_key?(libs, "Test 3") 
    assert Map.has_key?(libs, "Test 2") 
  end
end
