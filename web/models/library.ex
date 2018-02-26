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

  def insert_changeset(model, params \\ :invalid) do
    model
    |> cast(params, ~w(name url desc folder stars), [])
    |> validate_required([:name, :url, :desc, :folder])
  end

  def get_libraries(min_stars) do
    query =
      case Integer.parse(min_stars) do
        {int, _str}   -> from lib in Extop.Library, where: lib.stars >= ^int
        :error        -> Extop.Library
      end
    Extop.Repo.all(query)
    |> Enum.map(fn lib -> %{lib | commited: days_passed(lib.commited)} end)
    |> Enum.reduce(%{}, fn(lib, acc) -> 
      Map.merge(acc, %{lib.folder => [lib]}, fn _k, v1, v2 -> List.flatten(v1, v2) end) end)
  end

  defp days_passed(date) do 
    case Timex.parse(date, "{ISO:Extended}") do
      {:ok, result} -> Timex.diff(Timex.now, result, :days)
      {:error, _}   -> ""
    end
  end
end
