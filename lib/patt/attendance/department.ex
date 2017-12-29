defmodule Patt.Attendance.Department do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Department
  alias Patt.Attendance.Position


  schema "departments" do
    has_many :positions, Position
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Department{} = department, attrs) do
    department
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
