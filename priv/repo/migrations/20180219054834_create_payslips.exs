defmodule Patt.Repo.Migrations.CreatePayslips do
  use Ecto.Migration

  def change do
    create table(:payslips) do
      add :gross, :integer
      add :net, :integer
      add :regpay, :integer
      add :otpay, :integer
      add :leavepay, :integer
      add :sss, :integer
      add :pagibig, :integer
      add :philhealth, :integer
      add :undertime, :integer
      add :tardiness, :integer
      add :employee_id, references(:employees, on_delete: :nilify_all)
      add :payperiod_id, references(:payperiods, on_delete: :nilify_all)

      timestamps()
    end

    create index(:payslips, [:employee_id])
    create index(:payslips, [:payperiod_id])
  end
end
