defmodule Patt.Attendance.Dtr do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Dtr
  alias Patt.Attendance.Employee


  schema "dtrs" do
    belongs_to :employee, Employee

    field :date, :date
    field :in, :time
    field :out, :time
    field :sched_in, :time
    field :sched_out, :time
    field :daytype, :string
    field :ot, :boolean, default: false
    field :overtime, :integer, virtual: true
    field :undertime, :integer, virtual: true
    field :tardiness, :integer, virtual: true
    field :hw, :integer, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%Dtr{} = dtr, attrs) do
    dtr
    |> cast(attrs, [:date, :sched_in, :sched_out, :in, :out, :daytype, :ot])
    |> validate_required([:date])
  end
end
