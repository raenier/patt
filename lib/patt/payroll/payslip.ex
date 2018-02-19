defmodule Patt.Payroll.Payslip do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Payslip
  alias Patt.Payroll.Payperiod
  alias Patt.Attendance.Employee


  schema "payslips" do
    belongs_to :employee, Employee
    belongs_to :payperiod, Payperiod

    field :gross, :integer
    field :leavepay, :integer
    field :net, :integer
    field :otpay, :integer
    field :pagibig, :integer
    field :philhealth, :integer
    field :regpay, :integer
    field :sss, :integer
    field :tardiness, :integer
    field :undertime, :integer

    timestamps()
  end

  @doc false
  def changeset(%Payslip{} = payslip, attrs) do
    payslip
    |> cast(attrs, [:gross, :net, :regpay, :otpay, :leavepay, :sss, :pagibig, :philhealth, :undertime, :tardiness, :employee_id, :payperiod_id])
    |> validate_required([])
  end
end
