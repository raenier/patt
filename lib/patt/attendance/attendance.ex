defmodule Patt.Attendance do
  @moduledoc """
  The Attendance context.
  """

  import Ecto.Query, warn: false
  alias Patt.Repo

  alias Patt.Attendance.Employee

  def list_employees do
    Repo.all(Employee)
  end

  def get_employee!(id), do: Repo.get!(Employee, id)

  def create_employee(attrs \\ %{}) do
    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
  end

  def update_employee(%Employee{} = employee, attrs) do
    employee
    |> Employee.changeset(attrs)
    |> Repo.update()
  end

  def delete_employee(%Employee{} = employee) do
    Repo.delete(employee)
  end

  def change_employee(%Employee{} = employee) do
    Employee.changeset(employee, %{})
  end

  def search_employee(params) do
    case Integer.parse(params) do
      {number, _} ->
        Patt.Attendance.Employee
        |> Ecto.Query.where([e], e.id == ^number)
        |> Patt.Repo.all

      :error ->
        querystr = "%#{params}%"
        Patt.Attendance.Employee
        |> Ecto.Query.where([e], ilike(e.first_name, ^querystr) or
                                 ilike(e.middle_name, ^querystr) or
                                 ilike(e.last_name, ^querystr))
        |> Patt.Repo.all
    end
  end
end
