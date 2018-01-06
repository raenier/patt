defmodule Patt.Attendance do
  @moduledoc """
  The Attendance context.
  """

  import Ecto.Query, warn: false
  alias Patt.Repo
  alias Ecto.Multi

  alias Patt.Attendance.Employee
  alias Patt.Attendance.Department
  alias Patt.Attendance.Position
  alias Patt.Attendance.SchedProfile

  ###EMPLOYEE

  def list_employees do
    Repo.all(Employee)
  end

  def list_employees_wdassoc do
    Repo.all(Employee)
    |> Repo.preload([:position, :contribution, :compensation,
                     employee_sched:
                     [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]])
  end

  def get_employee!(id), do: Repo.get!(Employee, id)

  def get_employee_wdassoc!(id), do: Repo.get!(Employee, id)
    |> Patt.Repo.preload([:employee_sched, :contribution, :compensation])

  def create_employee(attrs \\ %{}) do
    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
  end

  def create_employee_nested(attrs \\ %{}) do
    %Employee{}
    |> Employee.changeset_nested(attrs)
    |> Repo.insert()
  end

  def update_employee(%Employee{} = employee, attrs) do
    employee
    |> Employee.changeset(attrs)
    |> Repo.update()
  end

  def update_employee_nested(%Employee{} = employee, attrs) do
    employee
    |> Employee.changeset_nested(attrs)
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
        |> Repo.all
        |> Repo.preload([:position, :employee_sched, :contribution, :compensation])

      :error ->
        querystr = "%#{params}%"
        Patt.Attendance.Employee
        |> Ecto.Query.where([e], ilike(e.first_name, ^querystr) or
                                 ilike(e.middle_name, ^querystr) or
                                 ilike(e.last_name, ^querystr))
        |> Repo.all
        |> Repo.preload([:position, :employee_sched, :contribution, :compensation])
    end
  end

  ###DEPARTMENT

  def create_department(attrs \\ %{}) do
    %Department{}
    |> Department.changeset(attrs)
    |> Repo.insert()
  end

  def list_departments do
    Repo.all(Department)
  end

  def list_departments_positions do
    list_departments() |> Enum.map(&(Repo.preload(&1, :positions)))
  end

  def list_departments_positions_kl do
    departments = list_departments_positions()
    Enum.map departments, fn dept ->
     {dept.name, Enum.map(dept.positions, &{&1.name, &1.id})}
    end
  end

  def delete_department(%Department{} = department) do
    Repo.delete(department)
  end


  ###POSITION

  def list_positions do
    Repo.all(Position)
  end

  def create_position(attrs \\ [], department) do
    Ecto.build_assoc(department, :positions, attrs)
    |> Position.changeset(%{})
    |> Repo.insert()
  end

  ###SCHED_PROFILES
  #
  def list_profiles do
    Repo.all(SchedProfile)
  end

  def list_profiles_kl do
    list_profiles()
    |> Enum.map(&{&1.name, &1.id})
  end

  def create_profile(attrs \\ %{}) do
    %SchedProfile{}
    |> SchedProfile.changeset(attrs)
    |> Repo.insert()
  end

  ###Populate DB
  def create_default_profile() do
    Multi.new
    |> Multi.insert(:profile1,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "07:00am to 04:00pm",
                                         time_in: ~T[07:00:00],
                                         time_out: ~T[16:00:00]}))
    |> Multi.insert(:profile2,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "08:00am to 05:00pm",
                                         time_in: ~T[08:00:00],
                                         time_out: ~T[17:00:00]}))
    |> Multi.insert(:profile3,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "09:00am to 06:00pm",
                                         time_in: ~T[09:00:00],
                                         time_out: ~T[18:00:00]}))
    |> Multi.insert(:profile4,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "10:00am to 07:00pm",
                                         time_in: ~T[10:00:00],
                                         time_out: ~T[19:00:00]}))
    |> Multi.insert(:profile5,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "11:00am to 08:00pm",
                                         time_in: ~T[11:00:00],
                                         time_out: ~T[20:00:00]}))
    |> Repo.transaction
  end

  def drop_all_profiles do
    Repo.delete_all(SchedProfile)
  end

  def create_default_dept_post() do
    dept1 = "IT DEPARTMENT"
    dept1desc = "department handles all the technological aspects of the company, as well as develop software needed"
    dept2 = "ACCOUNTING DEPARTMENT"
    dept2desc = "department is responsible for recording and reporting the cash flow transactions of a company. This department has some key roles and responsibilities, including accounts receivable, accounts payable, payroll, financial reporting, and maintaining financial controls."
    dept3 = "OPERATIONS DEPARTMENT"
    dept3desc = "department is in charge of all the operations and services that the company provides"
    dept4 = "HR DEPARTMENT"
    dept4desc = "department charged with finding, screening, recruiting and training job applicants, as well as administering employee-benefit programs"

    Multi.new
    |> Multi.insert(:department1,
                Department.changeset(%Department{},
                                      %{name: dept1,
                                        description: dept1desc}))
                                |> Multi.run(:position1, fn %{department1: department1} ->
                                    create_position(%{
                                      name: "In-house Developer",
                                      description: "Creates software needed by the company"
                                    }, department1)
                                    create_position(%{
                                      name: "IT Department Head",
                                      description: "Handles IT department"
                                    }, department1)
                                    create_position(%{
                                      name: "IT Staff",
                                      description: "In charge of troubleshooting computers"
                                    }, department1)
                                end)
    |> Multi.insert(:department2, Department.changeset(%Department{},
                                                        %{name: dept2,
                                                          description: dept2desc}))
                                |> Multi.run(:position2, fn %{department2: department2} ->
                                    create_position(%{
                                      name: "Accounting Supervisor",
                                      description: "Do Accounting"
                                    }, department2)
                                    create_position(%{
                                      name: "Finance Manager",
                                      description: "Handles finance"
                                    }, department2)
                                    create_position(%{
                                      name: "Accountant",
                                      description: "Do Accounting"
                                    }, department2)
                                end)
    |> Multi.insert(:department3, Department.changeset(%Department{},
                                                        %{name: dept3,
                                                          description: dept3desc}))
                                |> Multi.run(:position3, fn %{department3: department3} ->
                                    create_position(%{
                                      name: "Head Operations",
                                      description: "Supervises operations and services"
                                    }, department3)
                                    create_position(%{
                                      name: "Head Dispatcher",
                                      description: "Assigns drivers and helpers to operations"
                                    }, department3)
                                    create_position(%{
                                      name: "Dispatch",
                                      description: "Assist in dispatching"
                                    }, department3)
                                end)
    |> Multi.insert(:department4, Department.changeset(%Department{},
                                                        %{name: dept4,
                                                          description: dept4desc}))
                                |> Multi.run(:position4, fn %{department4: department4} ->
                                    create_position(%{
                                      name: "Chief HR",
                                      description: "Supervises HR department"
                                    }, department4)
                                    create_position(%{
                                      name: "Assistant HR",
                                      description: "Assist Chief HR"
                                    }, department4)
                                    create_position(%{
                                      name: "HR Consultant",
                                      description: "Incharge of hr matters"
                                    }, department4)
                                end)
    |> Repo.transaction
  end
end
