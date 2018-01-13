defmodule Patt.Repo.Migrations.CreateLeaves do
  use Ecto.Migration

  def change do
    create table(:leaves) do
      add :type, :string
      add :used, :integer
      add :remaining, :integer
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

  end
end
