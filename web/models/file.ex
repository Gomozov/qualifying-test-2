defmodule Extop.File do
  use Extop.Web, :model

  schema "files" do
    field :sha,        :string
    field :size,       :integer
    field :loaded,     :string
    timestamps()
  end
end
