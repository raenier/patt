defmodule PattWeb.EmployeeController do
  require Ecto.Query
  use PattWeb, :controller
  alias Patt.Attendance
  alias Patt.Attendance.Employee
  alias Patt.Attendance.EmployeeSched
  alias Patt.Payroll.Contribution

  def index(conn, _params) do
    employees = Attendance.list_employees_wdassoc()
    employees = Enum.sort_by employees, &(&1.last_name)
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    render conn, "index.html", employees: employees, positions: positions, schedprofiles: schedprofiles
  end

  def search(conn, %{"search" => %{"for" => params, "attr" => attr}}) do
    results = Attendance.search_employee(params, attr)
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    render conn, "index.html", employees: results, positions: positions, schedprofiles: schedprofiles
  end

  def new(conn, _params) do
    changeset = Employee.changeset_nested(%Employee{
      employee_sched: %EmployeeSched{},
      contribution: %Contribution{}
      }, %{})
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    render conn, "new.html", changeset: changeset, positions: positions, schedprofiles: schedprofiles
  end

  def create(conn, %{"employee" => params}) do
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    case Attendance.create_employee_multi(params) do
      {:ok, _employee} ->
        conn
        |> put_flash(:info, "Successfully created employee")
        |> redirect(to: employee_path(conn, :index))
      {:error, _failed_operation, changeset, _changes} ->
        conn
        |> render("new.html", changeset: changeset, positions: positions, schedprofiles: schedprofiles)
    end
  end

  def show(conn, %{"id" => id}) do
    employee = Attendance.get_employee!(id)

    render conn, "show.html", employee: employee
  end

  def update(conn, %{"id" => id, "employee" => params}) do
    employee = Attendance.get_employee_wdassoc!(id)
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    case Attendance.update_employee_multi(employee, params) do
      {:ok, _employee} ->
        conn
        |> put_flash(:info, "successfully updated")
        |> redirect(to: employee_path(conn, :index))
      {:error, _failed_operation, changeset, _changes} ->
        conn
        |> render("edit.html", changeset: changeset,
                                employee: employee,
                                positions: positions,
                                schedprofiles: schedprofiles)
      {:error, changeset} ->
        conn
        |> render("edit.html", changeset: changeset,
                                employee: employee,
                                positions: positions,
                                schedprofiles: schedprofiles)
    end
  end

  def delete(conn,%{"id" => id}) do
    employee = Attendance.get_employee!(id)

    case Attendance.delete_employee(employee) do
      {:ok, employee} ->
        conn
        |> put_flash(:info, "successfully deleted employee #{employee.first_name}")
        |> redirect(to: employee_path(conn, :delete_employee))
    end
  end

  def delete_employee(conn, _params) do
    employees = Attendance.list_employees()
    render conn, "delete_emp_index.html", employees: employees
  end
end
