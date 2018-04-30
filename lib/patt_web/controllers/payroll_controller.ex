defmodule PattWeb.PayrollController do
  use PattWeb, :controller
  alias Patt.Attendance
  alias Patt.Payroll
  alias Patt.Payroll.Payperiod
  alias Patt.Payroll.Payslip
  alias Patt.Attendance.Employee
  alias Patt.Attendance.Dtr
  alias Patt.Helper

  def index(conn, _params) do
    employees = Attendance.list_employees_post_dept()
    employees = Enum.sort_by employees, &(&1.last_name)
    render conn, "index.html", employees: employees
  end

  def new(conn, %{"id" => id}) do
    employee = Attendance.get_employee_wdassoc!(id)
    changeset = Employee.changeset_dtr(Map.put(employee, :dtrs, []), %{})
    range = ""
    usedleave = Payroll.used_leave(employee)
    payslip = %Payslip{}
    yearmonth =
      Date.utc_today
      |> Date.to_string
      |> String.slice(0, 7)

    render conn, "payslip.html",
      [
        employee: employee,
        changeset: changeset,
        range: range,
        usedleave: usedleave,
        payslip: payslip,
        yearmonth: yearmonth
      ]
  end

  def gen_dtr(conn, %{"id" => id, "generated" => %{"range" => range_params, "yearmonth" => yearmonth}}) do
    [year, month] = String.split yearmonth, "-"
    range = Helper.gen_range(String.to_integer(range_params), String.to_integer(year), String.to_integer(month))
    employee = Attendance.get_employee_wdtrs!(id, range)
    all_dtrs =
    Attendance.complete_dtr(employee.dtrs, range)
    |> Attendance.put_sched(employee)

    {:ok, employee} =
    Employee.changeset_dtr(employee, %{})
    |> Ecto.Changeset.put_assoc(:dtrs, all_dtrs)
    |> Patt.Repo.update()

    employee =
      employee
      |> Attendance.compute_penaltyhours()
      |> Attendance.sort_dtrs_bydate()

    changeset = Employee.changeset_dtr(employee, %{})
    daytypes = Payroll.daytype_list(employee)
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee)

    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date()

    render conn, "payslip.html",
    [
      employee: employee,
      changeset: changeset,
      range: range_params,
      daytypes: daytypes,
      totals: totals,
      usedleave: usedleave,
      holidays: holidays,
      payslip: payslip,
      yearmonth: yearmonth,
    ]
  end

  def up_dtr(conn, %{"id" => id, "employee" => emp_params, "generated" => %{"range" => range_params, "yearmonth" => yearmonth} }) do
    [year, month] = String.split yearmonth, "-"
    range = Helper.gen_range(String.to_integer(range_params), String.to_integer(year), String.to_integer(month))
    employee = Attendance.get_employee_wdtrs!(id, range)
    %{"dtrs" => dtrparams} = emp_params

    dtrs =
      dtrparams
      |> Attendance.convert_dtr_params()

    {:ok, employee} =
      employee
      |> Employee.changeset_dtr(%{"dtrs" => dtrs})
      |> Patt.Repo.update()

    employee =
      employee
      |> Attendance.compute_penaltyhours()
      |> Attendance.sort_dtrs_bydate()

    changeset = Employee.changeset_dtr(employee, %{})
    daytypes = Payroll.daytype_list(employee)
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee)
    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date()

    render conn, "payslip.html",
    [
      employee: employee,
      changeset: changeset,
      range: range_params,
      daytypes: daytypes,
      totals: totals,
      usedleave: usedleave,
      payslip: payslip,
      holidays: holidays,
      yearmonth: yearmonth,
    ]
  end

  def reset_dtrs(conn, %{"id" => id, "reset_dtrs" => %{"range" => range_params, "yearmonth" => yearmonth}}) do
    [year, month] = String.split yearmonth, "-"
    range = Helper.gen_range(String.to_integer(range_params), String.to_integer(year), String.to_integer(month))
    Attendance.reset_dtrs(id, range)

    #move onto context
    employee = Attendance.get_employee_wdtrs!(id, range)
    all_dtrs =
    Attendance.complete_dtr(employee.dtrs, range)
    |> Attendance.put_sched(employee)

    {:ok, employee} =
    Employee.changeset_dtr(employee, %{})
    |> Ecto.Changeset.put_assoc(:dtrs, all_dtrs)
    |> Patt.Repo.update()

    employee = Attendance.sort_dtrs_bydate(employee)

    changeset = Employee.changeset_dtr(employee, %{})
    daytypes = Payroll.daytype_list(employee)
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee)
    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date()

    render conn, "payslip.html",
    [
      employee: employee,
      changeset: changeset,
      range: range_params,
      daytypes: daytypes,
      totals: totals,
      usedleave: usedleave,
      payslip: payslip,
      holidays: holidays,
      yearmonth: yearmonth,
    ]
  end

  def gen_payslip(conn, %{"id" => id, "gen_payslip" => params }) do
    %{"range" => range_params,
      "yearmonth" => yearmonth,
      "sss_loan" => sss_loan,
      "hdmf_loan" => pagibig_loan,
      "office_loan" => office_loan,
      "bank_loan" => bank_loan,
      "healthcare" => healthcare,
      "other_pay" => other_pay,
      "feliciana" => fel,
      "others" => others,
      "otherpay_remarks" => otherpay_remarks,
      "otherded_remarks" => otherded_remarks,
      } = params

    [year, month] = String.split yearmonth, "-"
    range = Helper.gen_range(String.to_integer(range_params), String.to_integer(year), String.to_integer(month))

    employee = Attendance.get_employee_wdtrs!(id, range)
    all_dtrs =
      Attendance.complete_dtr(employee.dtrs, range)
      |> Attendance.put_sched(employee)

    employee =
      employee
      |> Attendance.compute_penaltyhours()
      |> Attendance.sort_dtrs_bydate()

    changeset = Employee.changeset_dtr(employee, %{})
    daytypes = Payroll.daytype_list(employee)
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee)

    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date()

    #USER input values
    userinputs = Payroll.get_user_inputs(
      sss_loan, pagibig_loan, office_loan, bank_loan,
      healthcare, other_pay, fel, others, otherpay_remarks,
      otherded_remarks
    )

    {:ok, payslip} = Payroll.compute_payslip(payslip, totals, userinputs, employee.dtrs)

    render conn, "payslip.html",
    [
      employee: employee,
      changeset: changeset,
      range: range_params,
      daytypes: daytypes,
      totals: totals,
      usedleave: usedleave,
      payslip: payslip,
      holidays: holidays,
      yearmonth: yearmonth,
    ]
  end

  def up_payslip(conn, params) do
    #for updating existing payslip
    redirect(conn, to: payroll_path(conn, :new, 4))
  end

  def print(conn, %{"payslip" => pid}) do
    payslip = Payroll.get_payslip!(pid)
    payslip = Patt.Repo.preload(payslip, [:payperiod, employee: [:compensation]])

    conn = put_layout conn, false

    render conn, "print.html",
    [
      payslip: payslip,
    ]
  end

  def print_index(conn, _params) do
    payperiods = Payroll.get_all_payperiod()
    render conn, "print_index.html", payperiods: payperiods
  end

  def print_bulk(conn, %{"id" => id}) do
    payperiod = Payroll.get_payperiod_payslip!(id)
    sorted = Enum.sort_by payperiod.payslips, fn ps -> unless is_nil(ps.employee), do: ps.employee.last_name end
    payperiod = Map.put(payperiod, :payslips, sorted)
    conn = put_layout conn, false
    render conn, "print_bulk.html", payperiod: payperiod
  end

  def print_summary(conn, %{"id" => id}) do
    payperiod = Payroll.get_payperiod_payslip!(id)
    sorted = Enum.sort_by payperiod.payslips, fn ps -> unless is_nil(ps.employee), do: ps.employee.last_name end
    payperiod = Map.put(payperiod, :payslips, sorted)

    totalnet = Enum.reduce payperiod.payslips, 0, fn(p, acc) -> acc + p.net end
    totalnet = if is_integer(totalnet), do: totalnet + 0.0, else: totalnet
    totalfel = Enum.reduce payperiod.payslips, 0, fn(p, acc) -> acc + p.feliciana end

    conn = put_layout conn, false
    render conn, "print_summary.html", payperiod: payperiod, totalnet: totalnet, totalfel: totalfel
  end

  def print_atm(conn, %{"id" => id}) do
    payperiod = Payroll.get_payperiod_payslip!(id)
    sorted = Enum.sort_by payperiod.payslips, fn ps -> unless is_nil(ps.employee), do: ps.employee.last_name end
    payperiod = Map.put(payperiod, :payslips, sorted)

    render conn, "print_atm.html", payperiod: payperiod
  end
end
