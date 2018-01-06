defmodule Patt.Repo.Migrations.AddAReferenceToEmployeeFromPosition do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add :position_id, references(:positions, on_delete: :nothing)
    end

    create index(:employees, [:position_id])
  end
end
