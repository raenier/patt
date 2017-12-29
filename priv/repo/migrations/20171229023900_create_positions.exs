defmodule Patt.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :name, :string
      add :description, :string
      add :department_id, references(:departments, on_delete: :nothing)

      timestamps()
    end

    create index(:positions, [:department_id])
  end
end
