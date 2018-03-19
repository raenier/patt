defmodule Patt.Payroll.Contribution do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Contribution
  alias Patt.Attendance.Employee


  schema "contributions" do
    field :pagibig_num, :integer
    field :philhealth_num, :integer
    field :sss_num, :integer
    belongs_to :employee, Employee

    timestamps()
  end

  @doc false
  def changeset(%Contribution{} = contribution, attrs) do
    contribution
    |> cast(attrs, [:sss_num, :pagibig_num, :philhealth_num,])
    |> validate_required([])
  end
end
