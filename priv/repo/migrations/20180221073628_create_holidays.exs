defmodule Patt.Repo.Migrations.CreateHolidays do
  use Ecto.Migration

  def change do
    create table(:holidays) do
      add :name, :string
      add :type, :string
      add :date, :date

      timestamps()
    end

  end
end
