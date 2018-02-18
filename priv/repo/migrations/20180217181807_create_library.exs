defmodule Extop.Repo.Migrations.CreateLibrary do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :name,     :string,  null: false
      add :url,      :string,  null: false
      add :desc,     :string,  null: false
      add :stars,    :integer
      add :commited, :string
      add :is_git,   :boolean
      add :folder,   :string,  null: false
      timestamps()
    end
  end
end
