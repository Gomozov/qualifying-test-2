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
    |> validate_required([:commited])
  end

  def insert_changeset(model, params \\ :invalid) do
    model
    |> cast(params, ~w(name url desc folder stars is_git), [])
    |> validate_required([:name, :url, :desc, :folder, :is_git])
  end

  def save_libraries(libs) do
    Extop.Repo.delete_all(Extop.Library)
    libs
      |> Enum.map(&Extop.Library.insert_changeset(%Extop.Library{}, &1))
      |> Enum.filter(&(&1.valid?))
      |> Enum.map(&Extop.Repo.insert!(&1))
  end

  def get_libraries(min_stars) do
    query =
      case Integer.parse(min_stars) do
        {int, _str}   -> from lib in Extop.Library, where: lib.stars >= ^int
        :error        -> Extop.Library
      end
    Extop.Repo.all(query)
    |> Enum.map(fn lib -> %{lib | commited: days_passed(lib.commited)} end)
    |> Enum.map(fn lib -> %{lib | desc: parse_for_link(lib.desc)} end)
    |> Enum.reduce(%{}, fn(lib, acc) -> 
      Map.merge(acc, %{lib.folder => [lib]}, fn _k, v1, v2 -> List.flatten(v1, v2) end) end)
  end

  def parse_for_link(desc) do
    case Regex.run(~r/(.+)?\[(.+?)\]\((.+?)\)(.+)?/, desc) do
      nil                             -> desc
      [^desc, str1, name, link, str2] -> str1<>"<a href=#{link}>#{name}</a>"<>str2
    end
  end

  def days_passed(date) do 
    case Timex.parse(date, "{ISO:Extended}") do
      {:ok, result} -> Timex.diff(Timex.now, result, :days)
      {:error, _}   -> nil
    end
  end
end
