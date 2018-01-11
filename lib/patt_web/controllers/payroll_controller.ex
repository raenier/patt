defmodule PattWeb.PayrollController do
  use PattWeb, :controller
  alias Patt.Attendance

  def index(conn, _params) do
    employees = Attendance.list_employees_post_dept()
    render conn, "index.html", employees: employees
  end

  def new(conn, %{"id" => id}) do
    employee = Attendance.get_employee_wdassoc!(id)
    render conn, "payslip.html", employee: employee
  end
end
