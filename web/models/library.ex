defmodule Extop.Library do
  use Extop.Web, :model

  schema "libraries" do
    field :name,        :string
    field :url,         :string
    field :desc,        :string
    field :stars,       :integer
    field :commited,    :string
    field :is_git,      :boolean
    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, ~w(name url desc), [])
    |> validate_required([:name, :url, :desc])
    |> unique_constraint(:name)
    |> check_url()
  end

  def check_url(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{url: url}} ->
        put_change(changeset, :is_git, String.contains?(url, "https://github.com/"))
      _ -> changeset
    end
  end
end
