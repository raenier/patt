defmodule Patt.Repo.Migrations.CreateBonus do
  use Ecto.Migration

  def change do
    create table(:bonus) do
      add :thirteenth, :float
      add :year, :date
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

    create index(:bonus, [:employee_id])
  end
end
