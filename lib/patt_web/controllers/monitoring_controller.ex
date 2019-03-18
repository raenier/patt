defmodule PattWeb.MonitoringController do
  use PattWeb, :controller
  alias Patt.Attendance

  def index(conn, _params) do
    employees =
      Attendance.list_employee_with_type(["regular", "probationary"])
      |> Enum.sort_by(&(&1.last_name))

    render conn, "index.html", employees: employees
  end

  def monitor(conn, %{"id" => emp_id}) do
    employee = Attendance.get_employee!(emp_id)
    state = 0
    render conn, "monitor.html", employee: employee, state: state
  end

  def get_stats(conn, %{"id" => emp_id, "stats" => %{"from" => from, "to" => to}}) do
    {:ok, from} = Date.from_iso8601(from)
    {:ok, to} = Date.from_iso8601(to)
    range = Date.range(from, to)
    employee = Attendance.get_employee_wdtrs!(emp_id, range)
    tardiness = Attendance.count_tardiness(employee.dtrs)
    undertime = Attendance.count_undertime(employee.dtrs)
    absent = Attendance.count_absent(employee.dtrs)
    state = 1
    render conn, "monitor.html",
      employee: employee,
      tardiness: tardiness,
      undertime: undertime,
      absent: absent,
      state: state
  end
end
