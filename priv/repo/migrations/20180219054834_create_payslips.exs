defmodule Patt.Repo.Migrations.CreatePayslips do
  use Ecto.Migration

  def change do
    create table(:payslips) do
      add :gross, :float
      add :net, :float
      add :regpay, :float
      add :otpay, :float
      add :leavepay, :float
      add :sss, :float
      add :pagibig, :float
      add :philhealth, :float
      add :undertime, :float
      add :tardiness, :float
      add :employee_id, references(:employees, on_delete: :nilify_all)
      add :payperiod_id, references(:payperiods, on_delete: :nilify_all)

      timestamps()
    end

    create index(:payslips, [:employee_id])
    create index(:payslips, [:payperiod_id])
  end
end
