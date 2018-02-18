defmodule Extop.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :sha,      :string,  null: false
      add :size,     :integer, null: false
      add :loaded,   :string,  null: false
      timestamps()
    end

    create unique_index(:files, [:sha])
  end
end
