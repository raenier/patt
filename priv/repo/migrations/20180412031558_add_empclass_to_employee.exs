defmodule Patt.Repo.Migrations.AddEmpclassToEmployee do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add :emp_class, :string
    end
  end
end
