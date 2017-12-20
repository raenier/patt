defmodule Patt.Attendance.Employee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Employee


  schema "employees" do
    field :bday, :date
    field :brgy, :string
    field :country, :string
    field :first_name, :string
    field :last_name, :string
    field :middle_name, :string
    field :street, :string
    field :town, :string

    timestamps()
  end

  @doc false
  def changeset(%Employee{} = employee, attrs) do
    employee
    |> cast(attrs, [:first_name, :middle_name, :last_name, :bday, :street, :brgy, :town, :country])
    |> validate_required([:first_name, :middle_name, :last_name, :bday, :street, :brgy, :town, :country])
  end
end
