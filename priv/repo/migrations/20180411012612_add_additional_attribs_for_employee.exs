defmodule Patt.Repo.Migrations.AddAdditionalAttribsForEmployee do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add :maiden_name, :string
      add :civil_status, :string
      add :date_hired, :date
      add :branch, :string
      add :employee_number, :integer
    end
  end
end
