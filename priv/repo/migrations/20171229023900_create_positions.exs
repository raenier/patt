defmodule Patt.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :name, :string
      add :description, :text
      add :department_id, references(:departments, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:positions, [:department_id])
  end
end
