defmodule Patt.Repo.Migrations.CreateCompensations do
  use Ecto.Migration

  def change do
    create table(:compensations) do
      add :basic, :bigint
      add :cola, :bigint
      add :clothing, :bigint
      add :travel, :bigint
      add :food, :bigint
      add :employee_id, references(:employees, on_delete: :nothing)

      timestamps()
    end

    create index(:compensations, [:employee_id])
  end
end
