defmodule ParserTest do
  use ExUnit.Case

  setup do
    file = 
    File.open!("test/testfile.md", [:read])
    |> IO.read(:all)

    {:ok, test_file: file}
  end

  test "Parser.parse_file test", %{test_file: file} do
    [result | _tail] = Extop.Parser.parse_file(file)
    assert result.folder == "Actors"
    assert result.is_git == true
    assert result.name   == "poolboy"
  end
end
