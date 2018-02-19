defmodule Patt.Payroll.Payperiod do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Payperiod
  alias Patt.Payroll.Payslip


  schema "payperiods" do
    has_many :payslips, Payslip
    field :from, :date
    field :to, :date

    timestamps()
  end

  @doc false
  def changeset(%Payperiod{} = payperiod, attrs) do
    payperiod
    |> cast(attrs, [:from, :to])
    |> validate_required([:from, :to])
  end
end
