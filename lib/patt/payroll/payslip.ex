defmodule Patt.Payroll.Payslip do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Payslip
  alias Patt.Payroll.Payperiod
  alias Patt.Attendance.Employee


  schema "payslips" do
    belongs_to :employee, Employee
    belongs_to :payperiod, Payperiod

    field :gross, :float
    field :leavepay, :float
    field :net, :float
    field :otpay, :float
    field :pagibig, :float
    field :philhealth, :float
    field :regpay, :float
    field :sss, :float
    field :tardiness, :float
    field :undertime, :float

    timestamps()
  end

  @doc false
  def changeset(%Payslip{} = payslip, attrs) do
    payslip
    |> cast(attrs, [:gross, :net, :regpay, :otpay, :leavepay, :sss, :pagibig, :philhealth, :undertime, :tardiness, :employee_id, :payperiod_id])
    |> validate_required([])
  end
end
