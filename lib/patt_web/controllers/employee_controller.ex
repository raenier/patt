defmodule PattWeb.EmployeeController do
  require Ecto.Query
  use PattWeb, :controller
  alias Patt.Attendance
  alias Patt.Attendance.Employee
  alias Patt.Attendance.EmployeeSched

  def index(conn, _params) do
    employees = Attendance.list_employees_wdassoc()
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()
    render conn, "index.html", employees: employees, positions: positions, schedprofiles: schedprofiles
  end

  def search(conn, %{"search" => %{"for" => params}}) do
    results = Attendance.search_employee(params)
    positions = Attendance.list_departments_positions_kl()
    render conn, "index.html", employees: results, positions: positions
  end

  def new(conn, _params) do
    changeset = Employee.changeset_nested(%Employee{employee_sched: %EmployeeSched{}}, %{})
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()
    render conn, "new.html", changeset: changeset, positions: positions, schedprofiles: schedprofiles
  end

  def create(conn, %{"employee" => params}) do
    positions = Attendance.list_departments_positions_kl()

    case Attendance.create_employee_nested(params) do
      {:ok, _employee} ->
        conn
        |> put_flash(:info, "Successfully created employee")
        |> redirect(to: employee_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html", changeset: changeset, positions: positions)
    end
  end

  def show(conn, %{"id" => id}) do
    employee = Attendance.get_employee!(id)
    render conn, "show.html", employee: employee
  end

  def update(conn, %{"id" => id, "employee" => params}) do
    employee = Attendance.get_employee_wdassoc!(id)
    positions = Attendance.list_departments_positions_kl()

    case Attendance.update_employee_nested(employee, params) do
      {:ok, _employee} ->
        conn
        |> put_flash(:info, "successfully updated")
        |> redirect(to: employee_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("edit.html", changeset: changeset, employee: employee, positions: positions)
    end
  end

  def delete(conn,%{"id" => id}) do
    employee = Attendance.get_employee!(id)
    case Attendance.delete_employee(employee) do
      {:ok, employee} ->
        conn
        |> put_flash(:info, "successfully deleted employee #{employee.first_name}")
        |> redirect(to: employee_path(conn, :index))
    end
  end
end
