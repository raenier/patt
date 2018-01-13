defmodule Patt.Repo.Migrations.CreateLeaves do
  use Ecto.Migration

  def change do
    create table(:leaves) do
      add :vl_used, :integer
      add :sl_used, :integer
      add :vl_total, :integer
      add :sl_total, :integer
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

  end
end
