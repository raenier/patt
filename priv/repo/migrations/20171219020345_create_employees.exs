defmodule Patt.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :bday, :date
      add :street, :string
      add :brgy, :string
      add :town, :string
      add :country, :string

      timestamps()
    end

  end
end
