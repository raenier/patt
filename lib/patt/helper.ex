defmodule Patt.Helper do
  import Ecto.Query, warn: false

  alias Patt.Repo
  alias Ecto.Multi
  alias Patt.Attendance.Department
  alias Patt.Attendance.SchedProfile
  alias Patt.Attendance

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
                                    Attendance.create_position(%{
                                      name: "In-house Developer",
                                      description: "Creates software needed by the company"
                                    }, department1)
                                    Attendance.create_position(%{
                                      name: "IT Department Head",
                                      description: "Handles IT department"
                                    }, department1)
                                    Attendance.create_position(%{
                                      name: "IT Staff",
                                      description: "In charge of troubleshooting computers"
                                    }, department1)
                                end)
    |> Multi.insert(:department2, Department.changeset(%Department{},
                                                        %{name: dept2,
                                                          description: dept2desc}))
                                |> Multi.run(:position2, fn %{department2: department2} ->
                                    Attendance.create_position(%{
                                      name: "Accounting Supervisor",
                                      description: "Do Accounting"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Finance Manager",
                                      description: "Handles finance"
                                    }, department2)
                                    Attendance.create_position(%{
                                      name: "Accountant",
                                      description: "Do Accounting"
                                    }, department2)
                                end)
    |> Multi.insert(:department3, Department.changeset(%Department{},
                                                        %{name: dept3,
                                                          description: dept3desc}))
                                |> Multi.run(:position3, fn %{department3: department3} ->
                                    Attendance.create_position(%{
                                      name: "Head Operations",
                                      description: "Supervises operations and services"
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Head Dispatcher",
                                      description: "Assigns drivers and helpers to operations"
                                    }, department3)
                                    Attendance.create_position(%{
                                      name: "Dispatch",
                                      description: "Assist in dispatching"
                                    }, department3)
                                end)
    |> Multi.insert(:department4, Department.changeset(%Department{},
                                                        %{name: dept4,
                                                          description: dept4desc}))
                                |> Multi.run(:position4, fn %{department4: department4} ->
                                    Attendance.create_position(%{
                                      name: "Chief HR",
                                      description: "Supervises HR department"
                                    }, department4)
                                    Attendance.create_position(%{
                                      name: "Assistant HR",
                                      description: "Assist Chief HR"
                                    }, department4)
                                    Attendance.create_position(%{
                                      name: "HR Consultant",
                                      description: "Incharge of hr matters"
                                    }, department4)
                                end)
    |> Repo.transaction
  end
end
