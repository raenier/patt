defmodule Patt.Payroll.Tax do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Tax
  alias Patt.Attendance.Employee


  schema "taxes" do
    belongs_to :employee, Employee

    field :tin, :integer
    field :wtax, :integer

    timestamps()
  end

  @doc false
  def changeset(%Tax{} = tax, attrs) do
    tax
    |> cast(attrs, [:tin, :wtax])
    |> validate_required([])
  end
end
