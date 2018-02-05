defmodule Patt.Repo.Migrations.CreateSchedProfiles do
  use Ecto.Migration

  def change do
    create table(:sched_profiles) do
      add :name, :string
      add :morning_in, :time
      add :morning_out, :time
      add :afternoon_in, :time
      add :afternoon_out, :time

      timestamps()
    end

  end
end
