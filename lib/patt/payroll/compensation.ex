defmodule Patt.Payroll.Compensation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Compensation
  alias Patt.Attendance.Employee


  schema "compensations" do
    belongs_to :employee, Employee

    field :basic, :integer
    field :rice, :integer
    field :communication, :integer
    field :meal, :integer
    field :transpo, :integer
    field :gasoline, :integer
    field :clothing, :integer

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
