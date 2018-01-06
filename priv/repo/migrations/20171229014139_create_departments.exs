defmodule Patt.Repo.Migrations.CreateDepartments do
  use Ecto.Migration

  def change do
    create table(:departments) do
      add :name, :string
      add :description, :text

      timestamps()
    end

  end
end
