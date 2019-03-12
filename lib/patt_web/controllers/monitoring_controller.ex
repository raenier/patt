defmodule PattWeb.MonitoringController do
  use PattWeb, :controller
  alias Patt.Attendance

  def index(conn, _params) do
    employees =
      Attendance.list_employee_with_type(["regular", "probationary"])
      |> Enum.sort_by(&(&1.last_name))

    render conn, "index.html", employees: employees
  end
end
