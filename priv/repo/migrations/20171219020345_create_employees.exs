defmodule Patt.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :birth_date, :date
      add :birth_place, :string
      add :contact_num, :bigint
      add :street, :string
      add :brgy, :string
      add :town, :string
      add :province, :string
      add :emp_type, :string

      timestamps()
    end

  end
end
