defmodule Patt.Repo.Migrations.CreateSchedProfiles do
  use Ecto.Migration

  def change do
    create table(:sched_profiles) do
      add :name, :string
      add :time_in, :time
      add :time_out, :time

      timestamps()
    end

  end
end
