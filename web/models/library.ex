defmodule Extop.Library do
  use Extop.Web, :model

  schema "libraries" do
    field :name,        :string
    field :url,         :string
    field :desc,        :string
    field :stars,       :integer
    field :commited,    :string
    field :is_git,      :boolean
    field :folder,      :string
    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, ~w(stars commited), [])
    |> validate_required([:stars, :commited])
  end
end
