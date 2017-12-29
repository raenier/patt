defmodule Patt.Attendance.Position do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Position
  alias Patt.Attendance.Department


  schema "positions" do
    belongs_to :department, Department
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Position{} = position, attrs) do
    position
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
