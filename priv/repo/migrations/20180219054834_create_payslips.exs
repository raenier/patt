defmodule Patt.Repo.Migrations.CreatePayslips do
  use Ecto.Migration

  def change do
    create table(:payslips) do
      add :regpay, :float
      add :allowance, :float
      add :otpay, :float
      add :vlpay, :float
      add :slpay, :float
      add :hopay, :float
      add :gross, :float
      add :net, :float

      add :sss, :float
      add :pagibig, :float
      add :philhealth, :float
      add :healthcare, :float
      add :wtax, :float
      add :loan, :float
      add :feliciana, :float
      add :other_deduction, :float
      add :undertime, :float
      add :absent, :float
      add :tardiness, :float

      add :employee_id, references(:employees, on_delete: :nilify_all)
      add :payperiod_id, references(:payperiods, on_delete: :nilify_all)

      timestamps()
    end

    create index(:payslips, [:employee_id])
    create index(:payslips, [:payperiod_id])
  end
end
