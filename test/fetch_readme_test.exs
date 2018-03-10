defmodule FetchReadmeTest do
  use Extop.ModelCase
  import Extop.TestHelpers

  setup do
    test_file = insert_file(sha: "4632e068d5889f042fe2d9254a9295e5f31a26c7", size: 6, loaded: "TestDate")
    {:ok, test_file: test_file}
  end

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

  test "check check_db function with already exist file" do
    Extop.FetchReadme.check_db({:ok, {"4632e068d5889f042fe2d9254a9295e5f31a26c7", 6, "123456"}})
    assert length(Extop.Repo.all(Extop.File)) == 1 
  end

  test "check check_db function with new file" do
    Extop.FetchReadme.check_db({:ok, {"4632e068d5889f042fe2d9254a9295e5f31a26c8", 6, "123457"}})
    assert length(Extop.Repo.all(Extop.File)) == 2 
  end
end
