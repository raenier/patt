defmodule Patt.Helper do
  import Ecto.Query, warn: false

  alias Patt.Repo
  alias Ecto.Multi
  alias Patt.Attendance.Department
  alias Patt.Attendance.SchedProfile
  alias Patt.Attendance

  def gen_range(rangepattern, year, month) do
    case rangepattern do
      13 ->
        {:ok, startr} = Date.new(year, month, 13)
        {:ok, endr} = Date.new(year, month, 27)
        Date.range(startr, endr)

      28 ->
        {:ok, startr} = Date.new(year, month-1, 28)
        {:ok, endr} = Date.new(year, month, 12)
        Date.range(startr, endr)

      11 ->
        {:ok, startr} = Date.new(year, month, 11)
        {:ok, endr} = Date.new(year, month, 25)
        Date.range(startr, endr)

      26 ->
        {:ok, startr} = Date.new(year, month-1, 26)
        {:ok, endr} = Date.new(year, month, 10)
        Date.range(startr, endr)
    end
  end

  def create_default_profile() do
    Multi.new
    |> Multi.insert(:profile1,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "07:00am to 04:00pm",
                                         morning_in: ~T[07:00:00],
                                         morning_out: ~T[11:00:00],
                                         afternoon_in: ~T[12:00:00],
                                         afternoon_out: ~T[16:00:00]}))
    |> Multi.insert(:profile2,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "08:00am to 05:00pm",
                                         morning_in: ~T[08:00:00],
                                         morning_out: ~T[12:00:00],
                                         afternoon_in: ~T[13:00:00],
                                         afternoon_out: ~T[17:00:00]}))
    |> Multi.insert(:profile3,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "08:30am to 05:30pm",
                                         morning_in: ~T[08:30:00],
                                         morning_out: ~T[12:30:00],
                                         afternoon_in: ~T[13:30:00],
                                         afternoon_out: ~T[17:30:00]}))
    |> Multi.insert(:profile4,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "08:00am to 07:00pm",
                                         morning_in: ~T[08:00:00],
                                         morning_out: ~T[12:30:00],
                                         afternoon_in: ~T[13:30:00],
                                         afternoon_out: ~T[19:00:00]}))
    |> Multi.insert(:profile5,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "09:00am to 06:00pm",
                                         morning_in: ~T[09:00:00],
                                         morning_out: ~T[13:00:00],
                                         afternoon_in: ~T[14:00:00],
                                         afternoon_out: ~T[18:00:00]}))
    |> Multi.insert(:profile6,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "10:00am to 07:00pm",
                                         morning_in: ~T[10:00:00],
                                         morning_out: ~T[14:00:00],
                                         afternoon_in: ~T[15:00:00],
                                         afternoon_out: ~T[19:00:00]}))
    |> Multi.insert(:profile7,
                SchedProfile.changeset(%SchedProfile{},
                                       %{name: "11:00am to 08:00pm",
                                         morning_in: ~T[11:00:00],
                                         morning_out: ~T[15:00:00],
                                         afternoon_in: ~T[16:00:00],
                                         afternoon_out: ~T[20:00:00]}))
    |> Repo.transaction
  end

  def drop_all_profiles do
    Repo.delete_all(SchedProfile)
  end

  def create_default_dept_post() do
    dept1 = "MARKETING"
    dept1desc = "Promotion of the companies products and services to people"
    dept2 = "ACCOUNTING"
    dept2desc = "department is responsible for recording and reporting the cash flow transactions of a company. This department has some key roles and responsibilities, including accounts receivable, accounts payable, payroll, financial reporting, and maintaining financial controls."
    dept3 = "OPERATIONS"
    dept3desc = "department is in charge of all the operations and services that the company provides"
    dept4 = "HUMAN RESOURCE"
    dept4desc = "department charged with finding, screening, recruiting and training job applicants, as well as administering employee-benefit programs"
    dept5 = "CONSTRUCTION"
    dept5desc = "In charge of the construction projects of the company"

    Multi.new
    |> Multi.insert(:department1,
                Department.changeset(%Department{},
                                      %{name: dept1,
                                        description: dept1desc}))
                                |> Multi.run(:position1, fn %{department1: department1} ->
                                    Attendance.create_position(%{
                                      name: "Marketing Staff",
                                      description: "Promotes products and services of company"
                                    }, department1)
                                    Attendance.create_position(%{
                                      name: "Department Manager",
                                      description: "Head of department"
                                    }, department1)
                                end)
    |> Multi.insert(:department2, Department.changeset(%Department{},
                                                        %{name: dept2,
                                                          description: dept2desc}))
                                |> Multi.run(:position2, fn %{department2: department2} ->
                                    Attendance.create_position(%{
                                      name: "Department Manager",
                                      description: "Head of department"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Supervisor",
                                      description: "Handles finance"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Accounting staff / portalet",
                                      description: "Accountant that handles accounting of portalet"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "A/R Analyst",
                                      description: "Accounts Receivable staff"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "A/P Analyst",
                                      description: "Accounts Payable analyst"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Store Accountant / feliciana",
                                      description: "Accountant that handles transactions of feliciana"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Purchasing Staff",
                                      description: "Handles purchasing transaction of company"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Collector",
                                      description: "Handles purchasing transaction of company"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Disbursement Analyst",
                                      description: "Handles disbursement transactions"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "OIC - Waterworks ",
                                      description: "Handles All waterworks transaction"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Accounting Staff",
                                      description: "Handles All waterworks transaction"
                                    }, department2)
                                end)
    |> Multi.insert(:department3, Department.changeset(%Department{},
                                                        %{name: dept3,
                                                          description: dept3desc}))
                                |> Multi.run(:position3, fn %{department3: department3} ->
                                    Attendance.create_position(%{
                                      name: "Operations Manager",
                                      description: "Supervises operations and services"
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Executive Assistant",
                                      description: "Assist Manager"
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Dispatcher",
                                      description: "Assist in dispatching"
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Custodian/Dispatcher",
                                      description: "Assist in dispatching"
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Pollution Control Officer",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "PCO/Liason Officer",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Safety Officer",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Messenger",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "DENR/Special Projects",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Office Staff",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "SM Team Head",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Jollibee Team Head",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Office Staff",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Operations Staff",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Portalet Team Head",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Office Staff",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Branch Supervisor",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Agriculturist",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Area Head",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Secretary",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Supervisor",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Jollibee Team Staff",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Admin Staff",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Branch Head",
                                      description: ""
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Portalet Team Staff",
                                      description: ""
                                    }, department3)
                                end)
    |> Multi.insert(:department4, Department.changeset(%Department{},
                                                        %{name: dept4,
                                                          description: dept4desc}))
                                |> Multi.run(:position4, fn %{department4: department4} ->
                                    Attendance.create_position(%{
                                      name: "Department Manager",
                                      description: "Supervises HR department"
                                    }, department4)
                                    Attendance.create_position(%{
                                      name: "HR Officer",
                                      description: "Assist Chief HR"
                                    }, department4)
                                    Attendance.create_position(%{
                                      name: "HR Consultant",
                                      description: "Incharge of hr matters"
                                    }, department4)
                                    Attendance.create_position(%{
                                      name: "IT Staff",
                                      description: ""
                                    }, department4)
                                end)
    |> Multi.insert(:department5, Department.changeset(%Department{},
                                                        %{name: dept5,
                                                          description: dept5desc}))
                                |> Multi.run(:position5, fn %{department5: department5} ->
                                    Attendance.create_position(%{
                                      name: "Head Engineer",
                                      description: ""
                                    }, department5)
                                    Attendance.create_position(%{
                                      name: "Project Engineer",
                                      description: ""
                                    }, department5)
                                    Attendance.create_position(%{
                                      name: "Field Engineer",
                                      description: ""
                                    }, department5)
                                    Attendance.create_position(%{
                                      name: "Office Staff",
                                      description: ""
                                    }, department5)
                                    Attendance.create_position(%{
                                      name: "Field Staff",
                                      description: ""
                                    }, department5)
                                    Attendance.create_position(%{
                                      name: "Accountant / Construction",
                                      description: ""
                                    }, department5)
                                end)
    |> Repo.transaction
  end

  def return_day_string(daynumber) do
    case daynumber do
      1 -> "mon"
      2 -> "tue"
      3 -> "wed"
      4 -> "thu"
      5 -> "fri"
      6 -> "sat"
      7 -> "sun"
    end
  end

  def get_attributes(struct = %{}) do
    struct
      |> Map.pop(:__meta__)
      |> elem(1)
      |> Map.pop(:__struct__)
      |> elem(1)
      |> Map.pop(:inserted_at)
      |> elem(1)
      |> Map.pop(:updated_at)
      |> elem(1)
      |> Map.keys
  end
end
