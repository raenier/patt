defmodule Patt.Repo.Migrations.AlterEmployeeSchedNilifyAllSchedProfile do
  use Ecto.Migration

  def up do
    drop constraint("employee_scheds", "employee_scheds_monday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_tuesday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_wednesday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_thursday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_friday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_saturday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_sunday_id_fkey")
    alter table(:employee_scheds) do
      modify :monday_id, references(:sched_profiles, on_delete: :nilify_all)
      modify :tuesday_id, references(:sched_profiles, on_delete: :nilify_all)
      modify :wednesday_id, references(:sched_profiles, on_delete: :nilify_all)
      modify :thursday_id, references(:sched_profiles, on_delete: :nilify_all)
      modify :friday_id, references(:sched_profiles, on_delete: :nilify_all)
      modify :saturday_id, references(:sched_profiles, on_delete: :nilify_all)
      modify :sunday_id, references(:sched_profiles, on_delete: :nilify_all)
    end
  end

  def down do
    drop constraint("employee_scheds", "employee_scheds_monday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_tuesday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_wednesday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_thursday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_friday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_saturday_id_fkey")
    drop constraint("employee_scheds", "employee_scheds_sunday_id_fkey")
    alter table(:employee_scheds) do
      modify :monday_id, references(:sched_profiles, on_delete: :nothing)
      modify :tuesday_id, references(:sched_profiles, on_delete: :nothing)
      modify :wednesday_id, references(:sched_profiles, on_delete: :nothing)
      modify :thursday_id, references(:sched_profiles, on_delete: :nothing)
      modify :friday_id, references(:sched_profiles, on_delete: :nothing)
      modify :saturday_id, references(:sched_profiles, on_delete: :nothing)
      modify :sunday_id, references(:sched_profiles, on_delete: :nothing)
    end
  end
end
