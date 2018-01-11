defmodule Patt.Attendance.Leave do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Leave


  schema "leaves" do
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
