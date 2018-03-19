defmodule Patt.Repo.Migrations.AddOtherPay do
  use Ecto.Migration

  def change do
    alter table(:payslips) do
      add :other_pay, :float
      add :bank_loan, :float
    end
  end
end
