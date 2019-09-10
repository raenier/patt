defmodule Patt.Repo.Migrations.AddFlagAttribsForContribution do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      add :check_pagibig, :boolean
      add :check_philhealth, :boolean
      add :check_sss, :boolean
    end
  end
end
