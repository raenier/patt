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
  alias Patt.Attendance.Dtr

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
    attrs =
    if Map.has_key?(changeset.changes, :emp_type) do
      case changeset.changes.emp_type do
        "probationary" ->
          Map.put(attrs, "leave",
                          %{"id" => employee.leave.id, "sl_used" => 0, "vl_used" => 0,
                                                      "vl_total" => 0, "sl_total" => 0})
        "regular" ->
          Map.put(attrs, "leave",
                          %{"id" => employee.leave.id, "sl_used" => 0, "vl_used" => 0,
                                                      "vl_total" => 6, "sl_total" => 6})
      end
    else
      attrs
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

  ###DTR

  def get_employee_wdtrs!(id,  %{} = range) do
    range = Enum.map range, fn date -> date end

    get_employee_wdassoc!(id)
    |> Repo.preload([
      dtrs: from(d in Dtr, where: d.date in ^range),
      employee_sched: ~w(monday tuesday wednesday thursday friday saturday sunday)a
    ])
  end

  def complete_dtr(dtrs, range) do
    new_dtrs =
      Enum.reduce range, [], fn (date, acc) ->
        if Enum.any?(dtrs, &(&1.date==date)), do: acc, else: [ %{date: date} | acc ]
      end

    [dtrs | new_dtrs] |> List.flatten() |> Enum.sort(&(&1.date <= &2.date))
  end

  def convert_dtr_params(dtrparams) do
    Enum.reduce dtrparams, %{}, fn(dtr, acc) ->
      list_mhin = String.split(elem(dtr, 1)["sched_in"], ":")
      list_mhout = String.split(elem(dtr, 1)["sched_out"], ":")
      list_mhain = String.split(elem(dtr, 1)["in"], ":")
      list_mhaout = String.split(elem(dtr, 1)["out"], ":")

      dtrchanged = %{elem(dtr, 1) | "sched_in" => %{"hour" => List.first(list_mhin), "minute" => List.last(list_mhin)}}
      dtrchanged = %{dtrchanged | "sched_out" => %{"hour" => List.first(list_mhout), "minute" => List.last(list_mhout)}}
      dtrchanged = %{dtrchanged | "in" => %{"hour" => List.first(list_mhain), "minute" => List.last(list_mhain)}}
      dtrchanged = %{dtrchanged | "out" => %{"hour" => List.first(list_mhaout), "minute" => List.last(list_mhaout)}}

      Map.put acc, elem(dtr, 0), dtrchanged
    end
  end

  def sort_dtrs_bydate(employee) do
    sorted_dtrs = Enum.sort_by employee.dtrs, &(Date.to_erl(&1.date))
    Map.put employee, :dtrs, sorted_dtrs
  end

  def reset_dtrs(employee_id, range) do
    range = Enum.map range, fn date -> date end

    from(d in Dtr, where: d.date in ^range and d.employee_id == ^employee_id)
    |> Patt.Repo.delete_all()
  end

  def put_sched(dtrs, %Employee{} = employee) do
    Enum.map dtrs, fn dtr ->
      case Date.day_of_week(dtr.date) do
        1 ->
          if employee.employee_sched.monday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.monday.time_in)
            Map.put(map1, :sched_out, employee.employee_sched.monday.time_out)
          else
            dtr
          end
        2 ->
          if employee.employee_sched.tuesday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.tuesday.time_in)
            Map.put(map1, :sched_out, employee.employee_sched.tuesday.time_out)
          else
            dtr
          end
        3 ->
          if employee.employee_sched.wednesday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.wednesday.time_in)
            Map.put(map1, :sched_out, employee.employee_sched.wednesday.time_out)
          else
            dtr
          end
        4 ->
          if employee.employee_sched.thursday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.thursday.time_in)
            Map.put(map1, :sched_out, employee.employee_sched.thursday.time_out)
          else
            dtr
          end
        5 ->
          if employee.employee_sched.friday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.friday.time_in)
            Map.put(map1, :sched_out, employee.employee_sched.friday.time_out)
          else
            dtr
          end
        6 ->
          if employee.employee_sched.saturday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.saturday.time_in)
            Map.put(map1, :sched_out, employee.employee_sched.saturday.time_out)
          else
            dtr
          end
        7 ->
          if employee.employee_sched.sunday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.sunday.time_in)
            Map.put(map1, :sched_out, employee.employee_sched.sunday.time_out)
          else
            dtr
          end
      end
    end
  end

  def compute_ot(dtr) do
    if dtr.in && dtr.out && :gt == Time.compare(dtr.out, dtr.sched_out) do
      Time.diff(dtr.out, dtr.sched_out) / 60
    end
  end
  def compute_ut(dtr) do
    if dtr.in && dtr.out && :lt == Time.compare(dtr.out, dtr.sched_out) do
      Time.diff(dtr.sched_out, dtr.out) / 60
    end
  end
  def compute_tard(dtr) do
    if dtr.in && dtr.out && :gt == Time.compare(dtr.in, dtr.sched_in) do
      Time.diff(dtr.in, dtr.sched_in) / 60
    end
  end

  def compute_penaltyhours(employee) do
    dtrs =
    Enum.map employee.dtrs, fn dtr ->
      overtime = compute_ot(dtr)
      undertime = compute_ut(dtr)
      tardiness = compute_tard(dtr)

      dtr
      |> Map.put(:overtime, overtime)
      |> Map.put(:undertime, undertime)
      |> Map.put(:tardiness, tardiness)
    end
    Map.put(employee, :dtrs, dtrs)
  end

end
