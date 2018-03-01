defmodule Patt.Repo.Migrations.CreateCompensations do
  use Ecto.Migration

  def change do
    create table(:compensations) do
      add :basic, :bigint
      add :allowance_ntaxable, :bigint
      add :allowance_taxable, :bigint
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

    create index(:compensations, [:employee_id])
  end
end
