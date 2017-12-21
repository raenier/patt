defmodule Patt.Attendance.Employee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Employee


  schema "employees" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :birth_date, :date
    field :birth_place, :string #notreq
    field :contact_num, :integer
    field :street, :string
    field :brgy, :string
    field :town, :string
    field :province, :string
    field :emp_type, :string

    timestamps()
  end

  @doc false
  def changeset(%Employee{} = employee, attrs) do
    employee
    |> cast(attrs, [:first_name, :middle_name, :last_name, :birth_date, :birth_place,
                    :contact_num, :street, :brgy, :town, :province, :emp_type])
    |> validate_required([:first_name, :middle_name, :last_name, :birth_date, :contact_num, :street,
                          :brgy, :town, :province, :emp_type])
  end
end
