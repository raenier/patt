defmodule Patt.Repo.Migrations.CreateDaytypes do
  use Ecto.Migration

  def change do
    create table(:daytypes) do
      add :type, :string
      add :rate, :integer

      timestamps()
    end

  end
end
