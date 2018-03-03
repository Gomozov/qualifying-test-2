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
  end

  def last_sha() do
    from(d in Extop.File, limit: 1, order_by: [desc: d.inserted_at])
    |> (&Extop.Repo.one(&1) || %{}).()
    |> Map.get(:sha)
  end
end
