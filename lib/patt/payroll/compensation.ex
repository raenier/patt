defmodule Patt.Payroll.Compensation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Compensation
  alias Patt.Attendance.Employee


  schema "compensations" do
    belongs_to :employee, Employee

    field :basic, :integer
    field :clothing, :integer
    field :cola, :integer
    field :food, :integer
    field :travel, :integer

    timestamps()
  end

  @doc false
  def changeset(%Compensation{} = compensation, attrs) do
    compensation
    |> cast(attrs, [:basic, :cola, :clothing, :travel, :food])
    |> validate_required([:basic])
  end
end
