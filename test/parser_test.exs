defmodule ParserTest do
  use Extop.ModelCase 
  # use ExUnit.Case

  test "Parser.parse_file function with one string" do
    file = 
    File.open!("test/testfile.md", [:read])
    |> IO.read(:all)

    [result | _tail] = Extop.Parser.parse_file(file)
    assert result.folder == "Actors"
    assert result.is_git == true
    assert result.name   == "poolboy"
  end

  test "Parser.parse_file function with Readme.md" do
    file = 
    File.open!("test/testfile2.md", [:read])
    |> IO.read(:all)

    list = Extop.Parser.parse_file(file)
    assert Kernel.length(list) == 1261
    list
      |> Enum.map(&Extop.Library.insert_changeset(%Extop.Library{}, &1))
      |> Enum.filter(&(&1.valid?))
      |> Enum.map(&Extop.Repo.insert!(&1))
    assert length(Extop.Repo.all(Extop.Library)) == 1261  
  end

  test "Parser.parse_file function with Readme.md containing error-line" do
    file = 
    File.open!("test/testfile3.md", [:read])
    |> IO.read(:all)

    list = Extop.Parser.parse_file(file)
    assert Kernel.length(list) == 1260
    list
      |> Enum.map(&Extop.Library.insert_changeset(%Extop.Library{}, &1))
      |> Enum.filter(&(&1.valid?))
      |> Enum.map(&Extop.Repo.insert!(&1))
    assert length(Extop.Repo.all(Extop.Library)) == 1259  
  end
end
