defmodule Patt.Repo.Migrations.AddOtherPay do
  use Ecto.Migration

  def change do
    alter table(:payslips) do
      add :other_pay, :float
    end
  end
end
