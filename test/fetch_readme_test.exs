defmodule FetchReadmeTest do
  use ExUnit.Case

  test "check validate_sha function with correct data" do
    {:ok, result} = Extop.FetchReadme.validate_sha({:ok, %{"content" => "MTIzNDU2", 
                        "size" => 6, "sha" => "4632e068d5889f042fe2d9254a9295e5f31a26c7"}})
    assert result == {"4632e068d5889f042fe2d9254a9295e5f31a26c7", 6, "123456"}
  end

  test "check validate_sha function with uncorrect data" do
    {:error, result} = Extop.FetchReadme.validate_sha({:ok, %{"content" => "MTIzNDU2", 
                        "size" => 6, "sha" => "123456"}})
    assert result == "Integrity violation"
  end

  test "check validate_sha function with error" do
    {:error, result} = Extop.FetchReadme.validate_sha({:error, "Some text"})
    assert result == "Handle response error"
  end

  test "check validate_sha function without required parameter" do
    {:error, result} = Extop.FetchReadme.validate_sha({:ok, %{"content" => "123456",
                           "size" => 6}})
    assert result == "Uncorrect data structure"
  end
end
