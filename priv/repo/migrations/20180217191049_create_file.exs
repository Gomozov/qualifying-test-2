defmodule Extop.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :sha,      :string
      add :size,     :integer
      add :loaded,   :string
      timestamps
    end

    create unique_index(:files, [:sha])
  end
end
