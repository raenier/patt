defmodule Patt.Attendance.Employee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.Employee
  alias Patt.Attendance.Position
  alias Patt.Attendance.EmployeeSched
  alias Patt.Payroll.Contribution
  alias Patt.Payroll.Compensation


  schema "employees" do
    belongs_to :position, Position
    has_one :employee_sched, EmployeeSched
    has_one :contribution, Contribution
    has_one :compensation, Compensation

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
                    :contact_num, :street, :brgy, :town, :province, :emp_type, :position_id])
    |> validate_required([:first_name, :middle_name, :last_name, :birth_date, :contact_num, :street,
                          :brgy, :town, :province, :emp_type])
  end

  def changeset_nested(%Employee{} = employee, attrs) do
    Employee.changeset(employee, attrs)
    |> cast_assoc(:employee_sched)
    |> cast_assoc(:contribution)
    |> cast_assoc(:compensation)
  end
end
