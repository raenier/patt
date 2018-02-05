defmodule Patt.Repo.Migrations.CreateDtrs do
  use Ecto.Migration

  def change do
    create table(:dtrs) do
      add :date, :date
      add :sched_in, :time
      add :sched_out, :time
      add :in, :time
      add :out, :time
      add :daytype, :string
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

    create index(:dtrs, [:employee_id])
  end
end
