defmodule Patt.Attendance.Position do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Position


  schema "positions" do
    field :description, :string
    field :name, :string
    field :dept_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Position{} = position, attrs) do
    position
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
