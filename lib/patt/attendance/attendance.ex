defmodule Patt.Attendance do
  @moduledoc """
  The Attendance context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Patt.Repo
  alias Patt.Attendance.Employee
  alias Patt.Attendance.Department
  alias Patt.Attendance.Position
  alias Patt.Attendance.SchedProfile
  alias Patt.Attendance.Leave

  ###EMPLOYEE

  def list_employees do
    Repo.all(Employee)
  end

  def list_employees_post_dept do
    list_employees()
    |> Repo.preload([position: :department])
  end

  def list_employees_wdassoc do
    list_employees()
    |> Repo.preload([:position, :contribution, :compensation, :tax,
                     employee_sched:
                     [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]])
  end

  def get_employee!(id), do: Repo.get!(Employee, id)

  def get_employee_wdassoc!(id), do: Repo.get!(Employee, id)
    |> Patt.Repo.preload([:position, :employee_sched, :contribution, :compensation, :tax, :leave])

  def create_employee(attrs \\ %{}) do
    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
  end

  def create_employee_multi(attrs \\ %{}) do
    Multi.new
    |> Multi.insert(:employee, Employee.changeset_nested(%Employee{}, attrs))
    |> Multi.run(:leave, fn %{employee: employee} ->
      if employee.emp_type == "regular" || employee.emp_type == "Regular" do
        #future-todo: all leave totals are persisted not hardcoded
        Ecto.build_assoc(employee, :leave, %{sl_used: 0, vl_used: 0, vl_total: 6, sl_total: 6})
        |> Repo.insert()
      else
        Ecto.build_assoc(employee, :leave, %{sl_used: 0, vl_used: 0, vl_total: 0, sl_total: 0})
        |> Repo.insert()
      end
    end )
    |> Repo.transaction()
  end

  def update_employee_nested(%Employee{} = employee, attrs) do
    employee
    |> Employee.changeset_nested(attrs)
    |> Repo.update()
  end

  def update_employee_multi(%Employee{} = employee, attrs) do
    changeset = Employee.changeset_nested(employee, attrs)
    if Map.has_key?(changeset.changes, :emp_type) do
      case changeset.changes.emp_type do
        "probationary" ->
          attrs = Map.put(attrs, "leave",
                          %{"id" => employee.leave.id, "sl_used" => 0, "vl_used" => 0,
                                                      "vl_total" => 0, "sl_total" => 0})
        "regular" ->
          attrs = Map.put(attrs, "leave",
                          %{"id" => employee.leave.id, "sl_used" => 0, "vl_used" => 0,
                                                      "vl_total" => 6, "sl_total" => 6})
      end
    end

    update_employee_nested(employee, attrs)
  end

  def delete_employee(%Employee{} = employee) do
    Repo.delete(employee)
  end

  def change_employee(%Employee{} = employee) do
    Employee.changeset(employee, %{})
  end

  def search_employee(params) do
    schemas = [:position, :employee_sched, :contribution, :compensation, :tax]

    case Integer.parse(params) do
      {number, _} ->
        Patt.Attendance.Employee
        |> Ecto.Query.where([e], e.id == ^number)
        |> Repo.all
        |> Repo.preload(schemas)

      :error ->
        querystr = "%#{params}%"
        Patt.Attendance.Employee
        |> Ecto.Query.where([e], ilike(e.first_name, ^querystr) or
                                 ilike(e.middle_name, ^querystr) or
                                 ilike(e.last_name, ^querystr))
        |> Repo.all
        |> Repo.preload(schemas)
    end
  end

  ###DEPARTMENT

  def create_department(attrs \\ %{}) do
    %Department{}
    |> Department.changeset(attrs)
    |> Repo.insert()
  end

  def list_departments do
    Repo.all(Department)
  end

  def list_departments_positions do
    list_departments() |> Enum.map(&(Repo.preload(&1, :positions)))
  end

  def list_departments_positions_kl do
    departments = list_departments_positions()
    Enum.map departments, fn dept ->
     {dept.name, Enum.map(dept.positions, &{&1.name, &1.id})}
    end
  end

  def delete_department(%Department{} = department) do
    Repo.delete(department)
  end


  ###POSITION

  def list_positions do
    Repo.all(Position)
  end

  def create_position(attrs \\ [], department) do
    Ecto.build_assoc(department, :positions, attrs)
    |> Position.changeset(%{})
    |> Repo.insert()
  end

  ###SCHED_PROFILES
  #
  def list_profiles do
    Repo.all(SchedProfile)
  end

  def list_profiles_kl do
    list_profiles()
    |> Enum.map(&{&1.name, &1.id})
  end

  def create_profile(attrs \\ %{}) do
    %SchedProfile{}
    |> SchedProfile.changeset(attrs)
    |> Repo.insert()
  end
end
