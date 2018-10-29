defmodule Patt.Repo.Migrations.AlterContributionTableType do
  use Ecto.Migration
  import Ecto.Query

  def up do
    alter table(:contributions) do
      add :pagibig, :string
      add :philhealth, :string
      add :sss, :string
    end

    flush()

    from(c in "contributions",
         update: [set: [pagibig: c.pagibig_num]])
    |> Patt.Repo.update_all([])

    from(c in "contributions",
         update: [set: [philhealth: c.philhealth_num]])
    |> Patt.Repo.update_all([])

    from(c in "contributions",
         update: [set: [sss: c.sss_num]])
    |> Patt.Repo.update_all([])

    alter table(:contributions) do
      remove :pagibig_num
      remove :philhealth_num
      remove :sss_num
    end
  end

  def down do
    alter table(:contributions) do
      add :pagibig_num, :integer
      add :philhealth_num, :integer
      add :sss_num, :integer
    end

    alter table(:contributions) do
      remove :pagibig
      remove :philhealth
      remove :sss
    end
  end
end
