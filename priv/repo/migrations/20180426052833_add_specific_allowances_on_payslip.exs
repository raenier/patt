defmodule Patt.Repo.Migrations.AddSpecificAllowancesOnPayslip do
  use Ecto.Migration

  def up do
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

  def down do
    alter table(:payslips) do
      add :ntallowance, :integer
      add :tallowance, :integer
      remove :rice
      remove :communication
      remove :meal
      remove :transpo
      remove :gasoline
      remove :clothing
    end
  end

end
