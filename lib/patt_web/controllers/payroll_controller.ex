defmodule PattWeb.PayrollController do
  use PattWeb, :controller
  alias Patt.Attendance
  alias Patt.Payroll
  alias Patt.Attendance.Employee
  alias Patt.Attendance.Dtr
  alias Patt.Helper

  def index(conn, _params) do
    employees = Attendance.list_employees_post_dept()
    render conn, "index.html", employees: employees
  end

  def new(conn, %{"id" => id}) do
    employee = Attendance.get_employee_wdassoc!(id)
    changeset = Employee.changeset_dtr(Map.put(employee, :dtrs, []), %{})
    range = ""
    usedleave = Payroll.used_leave(employee)

    render conn, "payslip.html",
      [
        employee: employee,
        changeset: changeset,
        range: range,
        usedleave: usedleave,
      ]
  end

  def gen_dtr(conn, %{"id" => id, "generated" => %{"range" => params}}) do
    range = Helper.gen_range(String.to_integer(params))
    employee = Attendance.get_employee_wdtrs!(id, range)
    all_dtrs =
    Attendance.complete_dtr(employee.dtrs, range)
    |> Attendance.put_sched(employee)

    {:ok, employee} =
    Employee.changeset_dtr(employee, %{})
    |> Ecto.Changeset.put_assoc(:dtrs, all_dtrs)
    |> Patt.Repo.update()

    employee =
      employee
      |> Attendance.compute_penaltyhours()
      |> Attendance.sort_dtrs_bydate()

    changeset = Employee.changeset_dtr(employee, %{})
    daytypes = Payroll.daytype_list(employee)
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee)

    render conn, "payslip.html",
    [
      employee: employee,
      changeset: changeset,
      range: params,
      daytypes: daytypes,
      totals: totals,
      usedleave: usedleave,
    ]
  end

  def up_dtr(conn, %{"id" => id, "employee" => emp_params, "generated" => %{"range" => range_params}}) do
    range = Helper.gen_range(String.to_integer(range_params))
    employee = Attendance.get_employee_wdtrs!(id, range)
    %{"dtrs" => dtrparams} = emp_params

    dtrs =
      dtrparams
      |> Attendance.convert_dtr_params()

    {:ok, employee} =
      employee
      |> Employee.changeset_dtr(%{"dtrs" => dtrs})
      |> Patt.Repo.update()

    employee =
      employee
      |> Attendance.compute_penaltyhours()
      |> Attendance.sort_dtrs_bydate()

    changeset = Employee.changeset_dtr(employee, %{})
    daytypes = Payroll.daytype_list(employee)
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee)

    render conn, "payslip.html",
    [
      employee: employee,
      changeset: changeset,
      range: range_params,
      daytypes: daytypes,
      totals: totals,
      usedleave: usedleave,
    ]
  end

  def reset_dtrs(conn, %{"id" => id, "reset_dtrs" => %{"range" => range_params}}) do
    range = Helper.gen_range(String.to_integer(range_params))
    Attendance.reset_dtrs(id, range)

    #move onto context
    employee = Attendance.get_employee_wdtrs!(id, range)
    all_dtrs =
    Attendance.complete_dtr(employee.dtrs, range)
    |> Attendance.put_sched(employee)

    {:ok, employee} =
    Employee.changeset_dtr(employee, %{})
    |> Ecto.Changeset.put_assoc(:dtrs, all_dtrs)
    |> Patt.Repo.update()

    employee = Attendance.sort_dtrs_bydate(employee)

    changeset = Employee.changeset_dtr(employee, %{})
    daytypes = Payroll.daytype_list(employee)
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee)

    render conn, "payslip.html",
    [
      employee: employee,
      changeset: changeset,
      range: range_params,
      daytypes: daytypes,
      totals: totals,
      usedleave: usedleave,
    ]
  end
end
