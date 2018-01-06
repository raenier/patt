defmodule Patt.Repo.Migrations.CreateTaxes do
  use Ecto.Migration

  def change do
    create table(:taxes) do
      add :tin, :bigint
      add :wtax, :bigint
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

    create index(:taxes, [:employee_id])
  end
end
