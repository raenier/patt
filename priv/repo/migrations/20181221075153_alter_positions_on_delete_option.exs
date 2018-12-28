defmodule Patt.Repo.Migrations.AlterPositionsOnDeleteOption do
  use Ecto.Migration

  def up do
    drop constraint("positions", "positions_department_id_fkey")
    alter table(:positions) do
      modify :department_id, references(:departments, on_delete: :delete_all)
    end
  end
  def down do
    drop constraint("positions", "positions_department_id_fkey")
    alter table(:positions) do
      modify :department_id, references(:departments, on_delete: :nothing)
    end
  end
end
