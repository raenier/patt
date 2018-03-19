defmodule Patt.Payroll.Compensation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Compensation
  alias Patt.Attendance.Employee


  schema "compensations" do
    belongs_to :employee, Employee

    field :basic, :integer
    field :allowance_ntaxable, :integer
    field :allowance_taxable, :integer

    timestamps()
  end

  @doc false
  def changeset(%Compensation{} = compensation, attrs) do
    compensation
    |> cast(attrs, [:basic, :allowance_ntaxable, :allowance_taxable])
    |> validate_required([])
  end
end
