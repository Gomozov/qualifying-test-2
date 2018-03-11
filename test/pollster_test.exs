defmodule PollsterTest do
  use Extop.ModelCase 
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Extop.TestHelpers

  setup context do
    insert_library(name: "phoenix", 
      url: "https://github.com/phoenixframework/phoenix", is_git: true)
    insert_library(name: "ecto", 
      url: "https://github.com/elixir-ecto/ecto", is_git: true)
    lib_test =
    cond do
      context[:github] -> insert_library(name: "httpoison", 
                            url: "https://github.com/edgurgel/httpoison", is_git: true)
      context[:hex]    -> insert_library(name: "data_morph", 
                            url: "https://hex.pm/packages/data_morph", is_git: false)
      context[:other]  -> insert_library(name: "Programming Phoenix", 
                            url: "https://pragprog.com/book/phoenix/programming-phoenix", is_git: false)
      true             -> insert_library(name: "httpoison", 
                            url: "https://github.com/123edgu/httpoiso/test123", is_git: true)
    end
    HTTPoison.start
    {:ok, lib_test: lib_test}
  end

  @tag :other
  test "take_info function with some url",
    %{lib_test: lib_test} do
    use_cassette "take_info some other library" do
      Extop.Pollster.take_info(lib_test, lib_test.is_git)
      lib = Extop.Repo.get_by(Extop.Library, name: lib_test.name)
      assert lib.stars == nil
      assert lib.commited == nil 
    end
  end

  @tag :hex
  test "take_info function with hex library",
    %{lib_test: lib_test} do
    use_cassette "take_info hex library" do
      Extop.Pollster.take_info(lib_test, lib_test.is_git)
      lib = Extop.Repo.get_by(Extop.Library, name: lib_test.name)
      assert lib.stars == nil
      assert lib.commited != nil 
    end
  end

  @tag :github
  test "take_info function with github library",
    %{lib_test: lib_test} do
    use_cassette "take_info github library" do
      Extop.Pollster.take_info(lib_test, lib_test.is_git)
      lib = Extop.Repo.get_by(Extop.Library, name: lib_test.name)
      assert lib.stars > 1000 
      assert lib.commited != nil 
    end
  end

  test "take_info function with uncorrect url",
    %{lib_test: lib_test} do
    use_cassette "take_info uncorrect url" do
      Extop.Pollster.take_info(%{lib_test | url: lib_test.url<>"/test"}, lib_test.is_git)
      lib = Extop.Repo.get_by(Extop.Library, name: lib_test.name)
      assert lib.stars == nil
      assert lib.commited == nil 
    end
  end

  @tag :github
  test "polling function with correct github data" do
    use_cassette "polling correct github data" do
      Extop.Pollster.polling()
      lib_1 = Extop.Repo.get_by(Extop.Library, name: "phoenix")
      lib_2 = Extop.Repo.get_by(Extop.Library, name: "ecto")
      lib_3 = Extop.Repo.get_by(Extop.Library, name: "httpoison")
      assert lib_1.stars > 10000 
      assert lib_2.stars > 3000 
      assert lib_3.stars > 1000 
      assert lib_1.commited != nil 
      assert lib_2.commited != nil 
      assert lib_3.commited != nil 
    end
  end

  @tag :hex
  test "polling function with correct github and hex data" do
    use_cassette "polling correct github and hex data" do
      Extop.Pollster.polling()
      lib_1 = Extop.Repo.get_by(Extop.Library, name: "phoenix")
      lib_2 = Extop.Repo.get_by(Extop.Library, name: "ecto")
      lib_3 = Extop.Repo.get_by(Extop.Library, name: "data_morph")
      assert lib_1.stars > 10000 
      assert lib_2.stars > 3000 
      assert lib_3.stars == nil
      assert lib_1.commited != nil 
      assert lib_2.commited != nil 
      assert lib_3.commited != nil 
    end
  end

  @tag :other
  test "polling function with correct github and other data" do
    use_cassette "polling correct github and other data" do
      Extop.Pollster.polling()
      lib_1 = Extop.Repo.get_by(Extop.Library, name: "phoenix")
      lib_2 = Extop.Repo.get_by(Extop.Library, name: "ecto")
      lib_3 = Extop.Repo.get_by(Extop.Library, name: "Programming Phoenix")
      assert lib_1.stars > 10000 
      assert lib_2.stars > 3000 
      assert lib_3.stars == nil
      assert lib_1.commited != nil 
      assert lib_2.commited != nil 
      assert lib_3.commited == nil 
    end
  end
end
