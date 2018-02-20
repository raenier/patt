defmodule Patt.Attendance.EmployeeSched do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.EmployeeSched
  alias Patt.Attendance.SchedProfile
  alias Patt.Attendance.Employee


  schema "employee_scheds" do
    belongs_to :employee, Employee

    belongs_to :monday, SchedProfile, foreign_key: :monday_id
    belongs_to :tuesday, SchedProfile, foreign_key: :tuesday_id
    belongs_to :wednesday, SchedProfile, foreign_key: :wednesday_id
    belongs_to :thursday, SchedProfile, foreign_key: :thursday_id
    belongs_to :friday, SchedProfile, foreign_key: :friday_id
    belongs_to :saturday, SchedProfile, foreign_key: :saturday_id
    belongs_to :sunday, SchedProfile, foreign_key: :sunday_id

    field :dpm, :integer

    timestamps()
  end

  @doc false
  def changeset(%EmployeeSched{} = employee_sched, attrs) do
    employee_sched
    |> cast(attrs, [:monday_id, :tuesday_id, :wednesday_id, :thursday_id,
                    :friday_id, :saturday_id, :sunday_id, :employee_id, :dpm])
    |> validate_required([])
  end
end
