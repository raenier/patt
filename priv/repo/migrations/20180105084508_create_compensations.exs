defmodule Patt.Repo.Migrations.CreateCompensations do
  use Ecto.Migration

  def change do
    create table(:compensations) do
      add :basic, :integer
      add :cola, :integer
      add :clothing, :integer
      add :travel, :integer
      add :food, :integer
      add :employee_id, references(:employees, on_delete: :nothing)

      timestamps()
    end

    create index(:compensations, [:employee_id])
  end
end
