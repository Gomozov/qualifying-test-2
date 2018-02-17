defmodule Extop.Repo.Migrations.CreateLibrary do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :name,     :string
      add :url,      :string
      add :desc,     :string
      add :stars,    :integer
      add :commited, :string
      add :is_git,   :boolean
      timestamps
    end

    create unique_index(:libraries, [:name])
  end
end
