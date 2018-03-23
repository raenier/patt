defmodule Patt.Repo.Migrations.AddRemarksOnPayslip do
  use Ecto.Migration

  def change do
    alter table(:payslips) do
      add :otherpay_remarks, :string
      add :otherded_remarks, :string
    end
  end
end
