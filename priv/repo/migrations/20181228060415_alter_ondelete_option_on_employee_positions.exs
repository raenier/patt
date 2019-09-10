defmodule Patt.Repo.Migrations.AlterOndeleteOptionOnEmployeePositions do
  use Ecto.Migration

  def up do
    drop constraint("employees", "employees_position_id_fkey")
    alter table("employees") do
      modify :position_id, references(:positions, on_delete: :nilify_all)
    end
  end
  def down do
    drop constraint("employees", "employees_position_id_fkey")
    alter table("employees") do
      modify :position_id, references(:positions, on_delete: :nothing)
    end
  end
end
