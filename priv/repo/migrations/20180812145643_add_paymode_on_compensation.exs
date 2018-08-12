defmodule Patt.Repo.Migrations.AddPaymodeOnCompensation do
  use Ecto.Migration

  def change do
    alter table(:compensations) do
      add :paymode, :string
    end
  end
end
