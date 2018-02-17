defmodule Extop.File do
  use Extop.Web, :model

  schema "files" do
    field :sha,        :string
    field :size,       :integer
    field :loaded,     :string
    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, ~w(sha size loaded), [])
    |> validate_required([:sha, :size, :loaded])
    |> unique_constraint(:sha)
  end
end
