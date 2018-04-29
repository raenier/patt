defmodule Patt.Repo.Migrations.AddSpecificAllowancesOnPayslip do
  use Ecto.Migration

  def change do
    alter table(:payslips) do
      remove :ntallowance
      remove :tallowance
      add :rice, :float
      add :communication, :float
      add :meal, :float
      add :transpo, :float
      add :gasoline, :float
      add :clothing, :float
    end
  end
end
