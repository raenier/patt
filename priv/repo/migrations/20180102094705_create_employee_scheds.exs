defmodule Patt.Repo.Migrations.CreateEmployeeScheds do
  use Ecto.Migration

  def change do
    create table(:employee_scheds) do
      add :employee_id, references(:employees, on_delete: :delete_all)

      add :monday_id, references(:sched_profiles, on_delete: :nothing)
      add :tuesday_id, references(:sched_profiles, on_delete: :nothing)
      add :wednesday_id, references(:sched_profiles, on_delete: :nothing)
      add :thursday_id, references(:sched_profiles, on_delete: :nothing)
      add :friday_id, references(:sched_profiles, on_delete: :nothing)
      add :saturday_id, references(:sched_profiles, on_delete: :nothing)
      add :sunday_id, references(:sched_profiles, on_delete: :nothing)

      add :dpm, :integer

      timestamps()
    end

    create index(:employee_scheds, [:employee_id])
    create index(:employee_scheds, [:monday_id])
    create index(:employee_scheds, [:tuesday_id])
    create index(:employee_scheds, [:wednesday_id])
    create index(:employee_scheds, [:thursday_id])
    create index(:employee_scheds, [:friday_id])
    create index(:employee_scheds, [:saturday_id])
    create index(:employee_scheds, [:sunday_id])
  end
end
