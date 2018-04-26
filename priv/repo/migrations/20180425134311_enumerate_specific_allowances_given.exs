defmodule Patt.Repo.Migrations.EnumerateSpecificAllowancesGiven do
  use Ecto.Migration

  def change do
    alter table(:compensations) do
      remove :allowance_ntaxable
      remove :allowance_taxable
      add :rice, :float
      add :communication, :float
      add :meal, :float
      add :transpo, :float
      add :gasoline, :float
      add :clothing, :float
    end

  end
end
