defmodule Patt.Repo.Migrations.AddSssPagibigOfficeLoan do
  use Ecto.Migration

  def change do
    alter table(:payslips) do
      remove :loan
      add :other_loan, :float
      add :sss_loan, :float
      add :hdmf_loan, :float
      add :office_loan, :float
    end
  end
end
