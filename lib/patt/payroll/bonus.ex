defmodule Patt.Payroll.Bonus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Employee

  schema "bonus" do
    field :thirteenth, :float
    field :year, :date

    belongs_to :employee, Employee

    timestamps()
  end

  @doc false
  def changeset(bonus, attrs) do
    bonus
    |> cast(attrs, [:thirteenth, :year, :employee_id])
    |> validate_required([:thirteenth, :year])
  end
end
