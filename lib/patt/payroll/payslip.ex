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
    field :ntallowance, :float
    field :tallowance, :float
    field :otpay, :float
    field :vlpay, :float
    field :slpay, :float
    field :rdpay, :float
    field :hopay, :float
    field :gross, :float
    field :net, :float

    field :sss, :float
    field :pagibig, :float
    field :philhealth, :float
    field :healthcare, :float
    field :wtax, :float
    field :other_loan, :float
    field :sss_loan, :float
    field :hdmf_loan, :float
    field :office_loan, :float
    field :bank_loan, :float
    field :other_pay, :float
    field :otherpay_remarks, :string
    field :feliciana, :float
    field :other_deduction, :float
    field :otherded_remarks, :string
    field :undertime, :float
    field :absent, :float
    field :tardiness, :float

    field :net_taxable, :float
    field :totalcompen, :float
    field :totaldeduction, :float


    timestamps()
  end

  @doc false
  def changeset(%Payslip{} = payslip, attrs) do
    payslip
    |> cast(attrs,
            [
              :gross, :net, :regpay, :otpay, :vlpay, :slpay, :rdpay,
              :sss, :pagibig, :philhealth, :undertime, :other_pay,
              :tardiness, :employee_id, :payperiod_id, :tallowance, :ntallowance,
              :hopay, :healthcare, :wtax, :other_loan, :feliciana, :absent, :other_deduction,
              :net_taxable, :totalcompen, :totaldeduction, :sss_loan, :hdmf_loan, :office_loan, :bank_loan,
              :otherpay_remarks, :otherded_remarks,
            ])
    |> validate_required([])
  end
end
