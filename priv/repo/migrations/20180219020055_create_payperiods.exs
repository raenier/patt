defmodule Patt.Repo.Migrations.CreatePayperiods do
  use Ecto.Migration

  def change do
    create table(:payperiods) do
      add :from, :date
      add :to, :date

      timestamps()
    end

  end
end
