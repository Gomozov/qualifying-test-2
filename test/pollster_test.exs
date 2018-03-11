defmodule PollsterTest do
  use Extop.ModelCase 
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Extop.TestHelpers

  setup context do
    insert_library(name: "phoenix", 
      url: "https://github.com/phoenixframework/phoenix", is_git: true)
    insert_library(name: "ecto", 
      url: "https://github.com/elixir-ecto/ecto", is_git: true)
    if context[:github] do
      insert_library(name: "httpoison", 
        url: "https://github.com/edgurgel/httpoison", is_git: true)
    end
    if context[:hex] do
      insert_library(name: "data_morph", 
        url: "https://hex.pm/packages/data_morph", is_git: false)
    end
    if context[:other] do
      insert_library(name: "Programming Phoenix", 
        url: "https://pragprog.com/book/phoenix/programming-phoenix", is_git: false)
    end
    HTTPoison.start
    :ok
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
