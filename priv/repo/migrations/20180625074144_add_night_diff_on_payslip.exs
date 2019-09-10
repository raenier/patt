defmodule Patt.Repo.Migrations.AddNightDiffOnPayslip do
  use Ecto.Migration

  def change do
    alter table(:payslips) do
      add :ndpay, :float
    end
  end
end
