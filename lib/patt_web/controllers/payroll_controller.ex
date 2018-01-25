defmodule PattWeb.PayrollController do
  use PattWeb, :controller
  alias Patt.Attendance
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
    render conn, "payslip.html", employee: employee, changeset: changeset, range: range
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

    #always sort dtrs by their date
    sorted_dtrs = Enum.sort employee.dtrs, &(&1.date<=&2.date)
    employee = Map.put employee, :dtrs, sorted_dtrs

    changeset = Employee.changeset_dtr(employee, %{})
    render conn, "payslip.html", employee: employee, changeset: changeset, range: params
  end

  def up_dtr(conn, %{"id" => id, "employee" => emp_params, "generated" => %{"range" => range_params}}) do
    range = Helper.gen_range(String.to_integer(range_params))
    employee = Attendance.get_employee_wdtrs!(id, range)
    %{"dtrs" => dtrparams} = emp_params

    dtrs = Attendance.convert_dtr_params(dtrparams)

    {:ok, employee} =
    Employee.changeset_dtr(employee, %{"dtrs" => dtrs})
    |> Patt.Repo.update()

    #sort employee dtrs by their date
    sorted_dtrs = Enum.sort employee.dtrs, &(&1.date<=&2.date)
    employee = Map.put employee, :dtrs, sorted_dtrs

    changeset = Employee.changeset_dtr(employee, %{})
    render conn, "payslip.html", employee: employee, changeset: changeset, range: range_params
  end
end
