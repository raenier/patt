defmodule PattWeb.EmployeeController do
  require IEx
  use PattWeb, :controller
  alias Patt.Attendance
  alias Patt.Attendance.Employee

  def index(conn, _params) do
    employees = Attendance.list_employees()
    render conn, "index.html", employees: employees
  end

  def new(conn, _params) do
    changeset = Employee.changeset(%Employee{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"employee" => params}) do
    case Attendance.create_employee(params) do
      {:ok, employee} ->
        conn
        |> put_flash(:info, "Successfully created employee")
        |> redirect(to: employee_path(conn, :show, employee))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    employee = Attendance.get_employee!(id)
    render conn, "show.html", employee: employee
  end

  def edit(conn, %{"id" => id}) do
    employee = Attendance.get_employee!(id)
    changeset = Attendance.change_employee(employee)
    render conn, "edit.html", employee: employee, changeset: changeset
  end

  def update(conn, %{"id" => id, "employee" => params}) do
    employee = Attendance.get_employee!(id)
    case Attendance.update_employee(employee, params) do
      {:ok, employee} ->
        conn
        |> put_flash(:info, "successfully updated")
        |> redirect(to: employee_path(conn, :show, employee))
      {:error, changeset} ->
        conn
        |> render("edit.html", changeset: changeset, employee: employee)
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
