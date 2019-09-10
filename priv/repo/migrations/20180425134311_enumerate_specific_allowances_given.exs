defmodule Patt.Repo.Migrations.EnumerateSpecificAllowancesGiven do
  use Ecto.Migration

  def up do
    alter table(:compensations) do
      remove :allowance_ntaxable
      remove :allowance_taxable
      add :rice, :integer
      add :communication, :integer
      add :meal, :integer
      add :transpo, :integer
      add :gasoline, :integer
      add :clothing, :integer
    end
  end

  def down do
    alter table(:compensations) do
      add :allowance_ntaxable, :integer
      add :allowance_taxable, :integer
      remove :rice
      remove :communication
      remove :meal
      remove :transpo
      remove :gasoline
      remove :clothing
    end
  end
end
