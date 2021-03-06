defmodule Patt.Attendance.Leave do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Leave
  alias Patt.Attendance.Employee


  schema "leaves" do
    belongs_to :employee, Employee

    field :vl_used, :integer, default: 0
    field :sl_used, :integer, default: 0
    field :vl_total, :integer, default: 0
    field :sl_total, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(%Leave{} = leave, attrs) do
    leave
    |> cast(attrs, [:vl_total, :sl_total, :vl_used, :sl_used])
    |> validate_required([:vl_total, :sl_total, :vl_used, :sl_used])
  end
end
