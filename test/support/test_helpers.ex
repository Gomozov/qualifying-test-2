defmodule Extop.TestHelpers do
  alias Extop.Repo

  def insert_library(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Library",
      url: "https://url.com",
      desc: "Description",
      folder: "Test",
      is_git: false,
    }, attrs)

    %Extop.Library{}
    |> Extop.Library.insert_changeset(changes)
    |> Repo.insert!()
  end

  def insert_file(attrs \\ %{}) do
    changes = Dict.merge(%{
      sha:    "TestTestTest",
      size:   1000,
      loaded: "SomeDate"
    }, attrs)

    %Extop.File{}
    |> Extop.File.changeset(changes)
    |> Repo.insert!()
  end
end
