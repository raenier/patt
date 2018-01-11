defmodule Patt.Repo.Migrations.CreateLeaves do
  use Ecto.Migration

  def change do
    create table(:leaves) do
      add :type, :string
      add :used, :integer
      add :remaining, :integer

      timestamps()
    end

  end
end
