defmodule Patt.AttendanceTest do
  use Patt.DataCase

  alias Patt.Attendance

  describe "employees" do
    alias Patt.Attendance.Employee

    @valid_attrs %{bday: ~D[2010-04-17], brgy: "some brgy", country: "some country", first_name: "some first_name", last_name: "some last_name", middle_name: "some middle_name", street: "some street", town: "some town"}
    @update_attrs %{bday: ~D[2011-05-18], brgy: "some updated brgy", country: "some updated country", first_name: "some updated first_name", last_name: "some updated last_name", middle_name: "some updated middle_name", street: "some updated street", town: "some updated town"}
    @invalid_attrs %{bday: nil, brgy: nil, country: nil, first_name: nil, last_name: nil, middle_name: nil, street: nil, town: nil}

    def employee_fixture(attrs \\ %{}) do
      {:ok, employee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Attendance.create_employee()

      employee
    end

    test "list_employees/0 returns all employees" do
      employee = employee_fixture()
      assert Attendance.list_employees() == [employee]
    end

    test "get_employee!/1 returns the employee with given id" do
      employee = employee_fixture()
      assert Attendance.get_employee!(employee.id) == employee
    end

    test "create_employee/1 with valid data creates a employee" do
      assert {:ok, %Employee{} = employee} = Attendance.create_employee(@valid_attrs)
      assert employee.bday == ~D[2010-04-17]
      assert employee.brgy == "some brgy"
      assert employee.country == "some country"
      assert employee.first_name == "some first_name"
      assert employee.last_name == "some last_name"
      assert employee.middle_name == "some middle_name"
      assert employee.street == "some street"
      assert employee.town == "some town"
    end

    test "create_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Attendance.create_employee(@invalid_attrs)
    end

    test "update_employee/2 with valid data updates the employee" do
      employee = employee_fixture()
      assert {:ok, employee} = Attendance.update_employee(employee, @update_attrs)
      assert %Employee{} = employee
      assert employee.bday == ~D[2011-05-18]
      assert employee.brgy == "some updated brgy"
      assert employee.country == "some updated country"
      assert employee.first_name == "some updated first_name"
      assert employee.last_name == "some updated last_name"
      assert employee.middle_name == "some updated middle_name"
      assert employee.street == "some updated street"
      assert employee.town == "some updated town"
    end

    test "update_employee/2 with invalid data returns error changeset" do
      employee = employee_fixture()
      assert {:error, %Ecto.Changeset{}} = Attendance.update_employee(employee, @invalid_attrs)
      assert employee == Attendance.get_employee!(employee.id)
    end

    test "delete_employee/1 deletes the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{}} = Attendance.delete_employee(employee)
      assert_raise Ecto.NoResultsError, fn -> Attendance.get_employee!(employee.id) end
    end

    test "change_employee/1 returns a employee changeset" do
      employee = employee_fixture()
      assert %Ecto.Changeset{} = Attendance.change_employee(employee)
    end
  end
end
