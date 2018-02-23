defmodule Patt.Payroll.Payslip do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Payslip
  alias Patt.Payroll.Payperiod
  alias Patt.Attendance.Employee


  schema "payslips" do
    belongs_to :employee, Employee
    belongs_to :payperiod, Payperiod

    field :regpay, :float
    field :allowance, :float
    field :otpay, :float
    field :vlpay, :float
    field :slpay, :float
    field :hopay, :float
    field :gross, :float
    field :net, :float

    field :sss, :float
    field :pagibig, :float
    field :philhealth, :float
    field :healthcare, :float
    field :wtax, :float
    field :loan, :float
    field :feliciana, :float
    field :other_deduction, :float
    field :undertime, :float
    field :absent, :float
    field :tardiness, :float

    timestamps()
  end

  @doc false
  def changeset(%Payslip{} = payslip, attrs) do
    payslip
    |> cast(attrs,
            [
              :gross, :net, :regpay, :otpay, :vlpay, :slpay,
              :sss, :pagibig, :philhealth, :undertime,
              :tardiness, :employee_id, :payperiod_id, :allowance,
              :hopay, :healthcare, :wtax, :loan, :feliciana, :absent, :other_deduction
            ])
    |> validate_required([])
  end
end
