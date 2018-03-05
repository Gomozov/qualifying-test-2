defmodule Extop.TestHelpers do
  alias Extop.Repo

  def insert_library(attrs \\ %{}) do
    changes = attrs |> Enum.into(%{name: "Library",
                                   url: "https://url.com",
                                   desc: "Description",
                                   folder: "Test",
                                   is_git: false})

    %Extop.Library{}
    |> Extop.Library.insert_changeset(changes)
    |> Repo.insert!()
  end

  def insert_file(attrs \\ %{}) do
    changes = attrs |> Enum.into(%{sha:    "TestTestTest",
                                   size:   1000,
                                   loaded: "SomeDate"})

    %Extop.File{}
    |> Extop.File.changeset(changes)
    |> Repo.insert!()
  end
end
