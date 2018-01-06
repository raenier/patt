defmodule Patt.Repo.Migrations.CreateContributions do
  use Ecto.Migration

  def change do
    create table(:contributions) do
      add :sss_num, :bigint
      add :sss_con, :bigint
      add :pagibig_num, :bigint
      add :pagibig_con, :bigint
      add :philhealth_num, :bigint
      add :philhealth_con, :bigint
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

    create index(:contributions, [:employee_id])
  end
end
