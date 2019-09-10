defmodule PattWeb.EmployeeController do
  require Ecto.Query
  use PattWeb, :controller
  alias Patt.Attendance
  alias Patt.Attendance.Employee
  alias Patt.Attendance.Department
  alias Patt.Attendance.Position
  alias Patt.Attendance.SchedProfile
  alias Patt.Attendance.EmployeeSched
  alias Patt.Payroll.Contribution

  def index(conn, _params) do
    employees = Attendance.list_employee_with_type(["regular", "probationary"])
    employees = Enum.sort_by employees, &(&1.last_name)
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    render conn, "index.html", employees: employees, positions: positions, schedprofiles: schedprofiles
  end

  def search(conn, %{"search" => %{"for" => params, "attr" => attr}}) do
    results = Attendance.search_employee(params, attr, ["regular", "probationary"])
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    render conn, "index.html", employees: results, positions: positions, schedprofiles: schedprofiles
  end

  def resigned_index(conn, _params) do
    employees = Attendance.list_employee_with_type(["resigned"])
    employees = Enum.sort_by employees, &(&1.last_name)
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    render conn, "resigned_index.html", employees: employees, positions: positions, schedprofiles: schedprofiles
  end

  def resigned_search(conn, %{"search" => %{"for" => params, "attr" => attr}}) do
    results = Attendance.search_employee(params, attr, ["resigned"])
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    render conn, "resigned_index.html", employees: results, positions: positions, schedprofiles: schedprofiles
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

  def resigned_update(conn, %{"id" => id, "employee" => params}) do
    employee = Attendance.get_employee_wdassoc!(id)
    positions = Attendance.list_departments_positions_kl()
    schedprofiles = Attendance.list_profiles_kl()

    case Attendance.update_employee_multi(employee, params) do
      {:ok, _employee} ->
        conn
        |> put_flash(:info, "successfully updated")
        |> redirect(to: employee_path(conn, :resigned_index))
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

  def sched_profile(conn, _params) do
    schedprofiles = Attendance.list_profiles_sorted()
    changeset = Patt.Attendance.SchedProfile.changeset(%SchedProfile{}, %{})
    render conn, "sched_profile.html", schedprofiles: schedprofiles, changeset: changeset
  end

  def add_sched(conn, %{"sched_profile" => sched_profile}) do
    %{ "afternoon_out" => to, "morning_in" => from } = sched_profile
    {:ok, from} = Time.from_iso8601(from <> ":00")
    {:ok, to} = Time.from_iso8601(to <> ":00")
    case Attendance.create_profile(%{morning_in: from, afternoon_out: to}) do
      {:ok, sched_profile} ->
        redirect conn, to: employee_path(conn, :sched_profile)

      {:error, changeset} ->
        redirect conn, to: employee_path(conn, :sched_profile)
    end
  end

  def delete_schedprofile(conn, %{"id" => id}) do
    schedprofile = Attendance.get_profile!(id)
    case Attendance.delete_profile(schedprofile) do
      {:ok, profile} ->
        redirect conn, to: employee_path(conn, :sched_profile)
    end
  end

  def department(conn, _params) do
    department =
      Attendance.list_departments_positions
      |> Enum.sort_by(&(&1.name))

    dept_changeset = Department.changeset(%Department{}, %{})
    post_changeset = Attendance.change_position(%Position{})
    render conn, "department.html",
      department: department,
      dept_changeset: dept_changeset,
      post_changeset: post_changeset
  end

  def create_dept(conn, %{"department" => attr}) do
    case Attendance.create_department(attr) do
      {:ok, _department} ->
        redirect conn, to: employee_path(conn, :department)
      {:error, _changeset} ->
        redirect conn, to: employee_path(conn, :department)
    end
  end

  def update_dept(conn, %{"department" => attrs, "id" => id}) do
    dept = Attendance.get_department!(id)
    Attendance.update_department(dept, attrs)
    redirect conn, to: employee_path(conn, :department)
  end

  def delete_dept(conn, %{"id" => id}) do
    dept = Attendance.get_department!(id)
    Attendance.delete_department(dept)
    redirect conn, to: employee_path(conn, :department)
  end

  def create_position(conn, %{"id" => dept_id, "position" => post_attrs}) do
    post_attrs = Map.put(post_attrs, "department_id", dept_id)
    IO.inspect post_attrs
    case Attendance.insert_position(post_attrs) do
      {:ok, _post} ->
        redirect conn, to: employee_path(conn, :department)
      {:error, _changeset} ->
        redirect conn, to: employee_path(conn, :department)
    end
  end

  def delete_position(conn, %{"id" => post_id}) do
    position = Attendance.get_position! post_id
    Attendance.delete_position position
    redirect conn, to: employee_path(conn, :department)
  end
end
