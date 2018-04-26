defmodule Patt.Payroll.Compensation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Compensation
  alias Patt.Attendance.Employee


  schema "compensations" do
    belongs_to :employee, Employee

    field :basic, :integer
    field :rice, :float
    field :communication, :float
    field :meal, :float
    field :transpo, :float
    field :gasoline, :float
    field :clothing, :float

    timestamps()
  end

  @doc false
  def changeset(%Compensation{} = compensation, attrs) do
    compensation
    |> cast(attrs, [
      :basic, :rice, :communication, :meal, :transpo, :gasoline, :clothing
    ])
    |> validate_required([])
  end
end
