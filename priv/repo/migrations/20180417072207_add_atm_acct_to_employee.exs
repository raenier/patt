defmodule Patt.Repo.Migrations.AddAtmAcctToEmployee do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add :atm_acct, :string
    end
  end
end
