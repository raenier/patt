defmodule Patt.Attendance.Leave do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Leave
  alias Patt.Attendance.Employee


  schema "leaves" do
    belongs_to :employee, Employee

    field :remaining, :integer
    field :type, :string
    field :used, :integer

    timestamps()
  end

  @doc false
  def changeset(%Leave{} = leave, attrs) do
    leave
    |> cast(attrs, [:type, :used, :remaining])
    |> validate_required([:type, :used, :remaining])
  end
end
