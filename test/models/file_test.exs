defmodule Extop.FileTest do
  use Extop.ModelCase, async: true 
  import Extop.TestHelpers
  alias Extop.File

  test "check last_sha function with empty DB" do
    assert File.last_sha == nil
  end

  test "check last_sha function with file in DB" do
    insert_file()
    assert File.last_sha == "TestTestTest"
  end

  test "changeset with valid attributes" do 
    changeset = File.changeset(%File{}, %{sha: "Test", size: 1000, loaded: "Date"})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do 
    changeset = File.changeset(%File{}, %{})
    refute changeset.valid?
  end
end
