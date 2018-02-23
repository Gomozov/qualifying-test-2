defmodule Extop.LibraryTest do
  use Extop.ModelCase, async: true 
  alias Extop.Library

  @valid_attrs %{name: "Library", url: "https://url.com", desc: "Description", folder: "Test"}
  @invalid_attrs %{}

  test "insert_changeset with valid attributes" do 
    changeset = Library.insert_changeset(%Library{}, @valid_attrs)
    assert changeset.valid?
  end

  test "insert_changeset with invalid attributes" do 
    changeset = Library.insert_changeset(%Library{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with valid attributes" do 
    changeset = Library.changeset(%Library{}, %{stars: 5, commited: "date"})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do 
    changeset = Library.changeset(%Library{}, @invalid_attrs)
    refute changeset.valid?
  end
end
