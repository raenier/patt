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
  alias Patt.Payroll

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
    |> Repo.preload([:contribution, :compensation, :tax,
                     employee_sched:
                     [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday],
                      position: :department,
                    ])
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

  def search_employee(params, criteria) do
    schemas = [:employee_sched, :contribution, :compensation, :tax, position: :department]
    query = generate_query(params, criteria)
    query
      |> Repo.all
      |> Repo.preload(schemas)
  end

  def generate_query(params, criteria) do
    querystr = "%#{params}%"
    case criteria do
      "id" ->
      case Integer.parse(params) do
        {number, _} ->
          Employee
          |> Ecto.Query.where([e], e.id == ^number)

        :error ->
          Employee
      end

      "fname" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.first_name, ^querystr) )

      "mname" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.middle_name, ^querystr) )

      "lname" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.last_name, ^querystr) )

      "street" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.street, ^querystr) )

      "brgy" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.brgy, ^querystr) )

      "town" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.town, ^querystr) )

      "province" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.province, ^querystr) )

      "emptype" ->
        Employee
          |> Ecto.Query.where([e], ilike(e.emp_type, ^querystr) )

      "department" ->
        Ecto.Query.from(
          e in Employee,
          join: p in assoc(e, :position),
          join: d in assoc(p, :department), where: ilike(d.name, ^querystr)
        )

      "position" ->
        Ecto.Query.from(
          e in Employee,
          join: p in assoc(e, :position),
          where: ilike(p.name, ^querystr)
        )

       true ->
        Employee
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
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.monday.morning_in)
            Map.put(map1, :sched_out, employee.employee_sched.monday.afternoon_out)
          else
            dtr
          end
        2 ->
          if employee.employee_sched.tuesday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.tuesday.morning_in)
            Map.put(map1, :sched_out, employee.employee_sched.tuesday.afternoon_out)
          else
            dtr
          end
        3 ->
          if employee.employee_sched.wednesday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.wednesday.morning_in)
            Map.put(map1, :sched_out, employee.employee_sched.wednesday.afternoon_out)
          else
            dtr
          end
        4 ->
          if employee.employee_sched.thursday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.thursday.morning_in)
            Map.put(map1, :sched_out, employee.employee_sched.thursday.afternoon_out)
          else
            dtr
          end
        5 ->
          if employee.employee_sched.friday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.friday.morning_in)
            Map.put(map1, :sched_out, employee.employee_sched.friday.afternoon_out)
          else
            dtr
          end
        6 ->
          if employee.employee_sched.saturday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.saturday.morning_in)
            Map.put(map1, :sched_out, employee.employee_sched.saturday.afternoon_out)
          else
            dtr
          end
        7 ->
          if employee.employee_sched.sunday do
            map1 = Map.put(dtr, :sched_in, employee.employee_sched.sunday.morning_in)
            Map.put(map1, :sched_out, employee.employee_sched.sunday.afternoon_out)
          else
            dtr
          end
      end
    end
  end

  #########miscellaneous
  def minute_diff(timeend,timestart) do
    res = Time.diff(timeend, timestart)
    if res < 0 do
      (res * -1)/60 - 360
    else
      res/60
    end
  end

  def fastforward(time, toadd) do
    {h, m, s} = Time.to_erl(time)
    sum = h + toadd
    sum = unless(sum = 24, do: sum, else: 0)
    {:ok, time} = Time.from_erl {sum, m, s}
    time
  end

  def backtrack(time, minus) do
    {h, m, s} = Time.to_erl(time)
    {:ok, time} = Time.from_erl {h - minus, m, s}
    time
  end

  def check_tardiness(tardiness) do
    tardiness <= 30 || is_nil(tardiness) || tardiness == ""
  end

  def all_inputs_complete(dtr) do
    dtr.sched_in && dtr.sched_out && dtr.out && dtr.in
  end

  def in_out_present(dtr) do
    dtr.in && dtr.out
  end

  def sched_and_in_present(dtr) do
    dtr.sched_in && dtr.sched_out && dtr.in
  end

  ###########

  def compute_ot(dtr) do
    if all_inputs_complete(dtr) do
      if dtr.ot do
        if dtr.out && Time.compare(dtr.out, dtr.sched_out) == :gt do
          actual = round(minute_diff(dtr.out, dtr.sched_out))
          if actual >= 60, do: actual-rem(actual, 30), else: 0
        else
          0
        end
      else
        0
      end
    end
  end

  def compute_ut(dtr) do
    if all_inputs_complete(dtr) do
      res =
        cond do
          Time.compare(dtr.out, dtr.sched_out) == :lt ->
            round(minute_diff(dtr.sched_out, dtr.out))

          true ->
            0
      end
    end
  end

  def compute_tard(dtr) do
    if sched_and_in_present(dtr) do
      res =
        cond do
          Time.compare(dtr.in, dtr.sched_in) == :gt ->
            round(minute_diff(dtr.in, dtr.sched_in))

          true ->
            0
        end
    end
  end

  # compute day totalwh
  # PM to am is anticipated
  def day_totalwh(dtr) do
    case Time.compare(dtr.sched_out, dtr.sched_in) do
      :gt ->
        round((Time.diff(dtr.sched_out, dtr.sched_in)/60) - 60)

      :eq ->
        round((Time.diff(dtr.sched_out, dtr.sched_in)/60) - 60)

      :lt ->
        time1 = round((Time.diff(~T[23:59:59], dtr.sched_in)/60) - 60)
        time2 = round((Time.diff(dtr.sched_out, ~T[00:00:00])/60))
        time1 + time2

      _matchany ->
        round((Time.diff(dtr.sched_out, dtr.sched_in)/60) - 60)
    end
  end

  def actual_workhours(dtr, tardiness, undertime) do
    if all_inputs_complete(dtr) do
      tard = unless is_nil(tardiness), do: tardiness, else: 0
      ut = unless is_nil(undertime), do: undertime, else: 0
      day_totalwh(dtr) - (tard + ut)
    end
  end

  #compute based on daytypes
  #TODO Edit restday and halfday computation
  def process_workhours(dtr) do
    case dtr.daytype do
      "regular" ->
        tardiness = compute_tard(dtr)
        undertime = compute_ut(dtr)
        totalwh = actual_workhours(dtr, tardiness, undertime)

        %{
          overtime: if(check_tardiness(tardiness), do: compute_ot(dtr), else: 0),
          undertime: undertime,
          tardiness: tardiness,
          hw: totalwh
        }

      "ob" ->
        tardiness = compute_tard(dtr)
        undertime = compute_ut(dtr)
        totalwh = actual_workhours(dtr, tardiness, undertime)

        %{
          overtime: if(check_tardiness(tardiness), do: compute_ot(dtr), else: 0),
          undertime: undertime,
          tardiness: tardiness,
          hw: totalwh
        }

      #undertime = tardiness + undertime
      "halfday" ->
        mtotalwh = (day_totalwh(dtr) - round(day_totalwh(dtr)/2))

        tardiness = compute_tard(dtr) - mtotalwh
        tard = unless(tardiness < 0, do: tardiness, else: 0)
        undertime = compute_ut(dtr)
        ut = if(is_nil(undertime), do: 0 + mtotalwh, else: undertime + mtotalwh)

        totalwh = actual_workhours(dtr, tard, ut)

        %{
          overtime: 0,
          undertime: ut,
          tardiness: tard,
          hw: totalwh
        }

      "restday" ->
        tardiness = compute_tard(dtr)
        undertime = compute_ut(dtr)
        totalwh = actual_workhours(dtr, tardiness, undertime)

        %{
          overtime: compute_ot(dtr),
          undertime: 0,
          tardiness: 0,
          hw: totalwh
        }

      "vl" ->
        %{
          overtime: 0,
          undertime: 0,
          tardiness: 0,
          hw: 0
        }

      "sl" ->
        %{
          overtime: 0,
          undertime: 0,
          tardiness: 0,
          hw: 0
        }

      _any ->
        %{
          overtime: "",
          undertime: "",
          tardiness: "",
          hw: ""
        }
    end
  end

  #put all computations on employee struct virtual fields
  def compute_penaltyhours(employee) do
    dtrs =
    Enum.map employee.dtrs, fn dtr ->
      result = process_workhours(dtr)

      dtr
      |> Map.put(:overtime, result.overtime)
      |> Map.put(:undertime, result.undertime)
      |> Map.put(:tardiness, result.tardiness)
      |> Map.put(:hw, result.hw)
    end

    Map.put(employee, :dtrs, dtrs)
  end


  # compute total for employee for that cutoff
  # Tallying
  # REVIEW
  # move all tallying here even holidays

  def overall_totals(dtrs) do
    minutesworked =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
        hw = unless is_nil(dtr.hw) || dtr.hw == "", do: dtr.hw, else: 0
        hw + acc
      end

    overtime =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
        ot = unless is_nil(dtr.overtime) || dtr.overtime == "", do: dtr.overtime, else: 0
        ot + acc
      end

    undertime =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
        ut = unless is_nil(dtr.undertime) || dtr.undertime == "", do: dtr.undertime, else: 0
        ut + acc
      end

    #count total minutes of absent
    absent =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
        ho = Patt.Payroll.get_holiday_bydate(dtr.date)
        unless dtr.daytype == "vl" || dtr.daytype == "sl" || dtr.daytype == "restday" || ho do
          if (dtr.sched_in && dtr.sched_out) && (is_nil(dtr.in) && is_nil(dtr.out)) do
            absent = round((Time.diff(dtr.sched_out, dtr.sched_in)/60) - 60)
            absent + acc
          else
            acc
          end
        else
          acc
        end
      end

    #count total days of absent
    absentdays =
     Enum.count dtrs, fn dtr ->
        ho = Patt.Payroll.get_holiday_bydate(dtr.date)
        unless dtr.daytype == "vl" || dtr.daytype == "sl" || dtr.daytype == "restday" || ho do
          if (dtr.sched_in && dtr.sched_out) && (is_nil(dtr.in) && is_nil(dtr.out)) do
            true
          else
            false
          end
        else
          false
        end
      end

    #count total work minutes skipping restday that has no actual in and out
    #Count actual work days and employee actual work in
    #
    totalwm =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
        ho = Patt.Payroll.get_holiday_bydate(dtr.date)
        if dtr.sched_in && dtr.sched_out do
          unless dtr.daytype == "restday" || dtr.daytype == "vl" || dtr.daytype == "sl" || ho  do
            twh = day_totalwh(dtr)
            twh + acc
          else
            acc
          end
        else
          acc
        end
      end

    #count days of work
    daycount =
      Enum.count dtrs, fn dtr ->
        if dtr.sched_in && dtr.sched_out do
          ho = Patt.Payroll.get_holiday_bydate(dtr.date)
          unless dtr.daytype == "restday" || dtr.daytype == "vl" || dtr.daytype == "sl" || ho  do
            true
          else
            false
          end
        else
          false
        end
      end

    tardiness =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
          #add another condition if day is holiday then dont compute tardiness
          holiday = Payroll.get_holiday_bydate(dtr.date)

        td =
          if is_nil(holiday) do
            unless is_nil(dtr.tardiness) || dtr.tardiness == "" do
              cond do
                dtr.tardiness > 5 ->
                  dtr.tardiness

                true ->
                  0
              end
            else
              0
            end
          else
            0
          end

        acc + td
      end

    vl =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
        if dtr.sched_in && dtr.sched_out && dtr.daytype == "vl" do
            twh = round((Time.diff(dtr.sched_out, dtr.sched_in)/60) - 60)
            twh + acc
        else
          acc
        end
      end

    sl =
      Enum.reduce dtrs, 0, fn(dtr, acc) ->
        if dtr.sched_in && dtr.sched_out && dtr.daytype == "sl" do
            twh = round((Time.diff(dtr.sched_out, dtr.sched_in)/60) - 60)
            twh + acc
        else
          acc
        end
      end

    totals = %{
      ot: overtime,
      ut: undertime,
      tard: tardiness,
      mw: minutesworked,
      absent: absentdays,
      daysofwork: daycount,
      vl: vl,
      sl: sl,
      totalwm: totalwm,
      totalabs: absent,
    }
  end
end
