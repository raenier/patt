defmodule PattWeb.PayrollController do
  use PattWeb, :controller
  import Ecto.Query
  alias Patt.Attendance
  alias Patt.Payroll
  alias Patt.Payroll.Payslip
  alias Patt.Payroll.Payperiod
  alias Patt.Attendance.Employee
  alias Patt.Attendance.Dtr
  alias Patt.Helper

  def index(conn, _params) do
    employees = Attendance.list_employees_post_dept_with_type(["regular", "probationary"])
    employees = Enum.sort_by employees, &(&1.last_name)
    render conn, "index.html", employees: employees
  end

  def new(conn, %{"id" => id}) do
    employee = Attendance.get_employee_wdassoc!(id)
    changeset = Employee.changeset_dtr(Map.put(employee, :dtrs, []), %{})
    range = ""
    usedleave = Payroll.used_leave(employee, Date.utc_today.year)
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
    daytypes = Payroll.daytype_list(employee, String.to_integer(year))
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee, String.to_integer(year))

    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date(String.to_integer(year))

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
    daytypes = Payroll.daytype_list(employee, String.to_integer(year))
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee, String.to_integer(year))
    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date(String.to_integer(year))

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
    daytypes = Payroll.daytype_list(employee, String.to_integer(year))
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee, String.to_integer(year))
    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date(String.to_integer(year))

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
    daytypes = Payroll.daytype_list(employee, String.to_integer(year))
    totals = Attendance.overall_totals(employee.dtrs)
    usedleave = Payroll.used_leave(employee, String.to_integer(year))

    #forgeneratingpayslip
    payperiod = Payroll.get_else_create_payperiod(range.first, range.last)
    payslip = Payroll.get_ps_else_new(employee.id, payperiod.id)
    holidays = Payroll.list_holidays_date(String.to_integer(year))

    #USER input values
    userinputs = Payroll.get_user_inputs(
      sss_loan, pagibig_loan, office_loan, bank_loan,
      healthcare, other_pay, fel, others, otherpay_remarks,
      otherded_remarks
    )

    #TODO: Create condition that separates computation for mgr and spv
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

  def up_payslip(conn, _params) do
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
    payperiods =
      Payroll.get_all_payperiod()
      |> Enum.sort_by(fn pp -> Date.to_erl(pp.to) end)
    opt = %{ fel: :feliciana, bankloan: :bankloan, all: :all, totals: :totals, sign: :sign, ca: :ca, net: :net}
    render conn, "print_index.html", payperiods: payperiods, opt: opt
  end

  def print_bulk(conn, %{"id" => id}) do
    payperiod = Payroll.get_payperiod_payslip!(id)
    sorted = Enum.sort_by payperiod.payslips, fn ps -> unless is_nil(ps.employee), do: ps.employee.last_name end
    payperiod = Map.put(payperiod, :payslips, sorted)
    conn = put_layout conn, false
    render conn, "print_bulk.html", payperiod: payperiod
  end

  def print_summary(conn, %{"id" => id, "opt" => opt}) do
    payperiod = Payroll.get_payperiod_payslip!(id)
    sorted = Enum.sort_by payperiod.payslips, fn ps -> unless is_nil(ps.employee), do: ps.employee.last_name end
    payperiod = Map.put(payperiod, :payslips, sorted)

    totals = Payroll.summary_totals(payperiod.payslips)

    conn = put_layout conn, false
    case opt do
      "feliciana" ->
        render conn, "print_fel.html", payperiod: payperiod, totals: totals

      "bankloan" ->
        render conn, "print_bankloan.html", payperiod: payperiod, totals: totals

      "all" ->
        render conn, "print_all.html", payperiod: payperiod, totals: totals

      "totals" ->
        render conn, "print_summary.html", payperiod: payperiod, totals: totals

      "ca" ->
        render conn, "print_ca.html", payperiod: payperiod, totals: totals

      "sign" ->
        render conn, "print_sign.html", payperiod: payperiod, totals: totals

      "net" ->
        render conn, "print_net.html", payperiod: payperiod, totals: totals
    end
  end

  def print_atm(conn, %{"id" => id}) do
    payperiod = Payroll.get_payperiod_payslip!(id)
    sorted = Enum.sort_by payperiod.payslips, fn ps -> unless is_nil(ps.employee), do: ps.employee.last_name end
    payperiod = Map.put(payperiod, :payslips, sorted)

    render conn, "print_atm.html", payperiod: payperiod
  end

  def report(conn, _params) do
    employees = Attendance.list_employees_post_dept_with_type(["regular", "probationary"])
    employees = Patt.Repo.preload(employees, :bonus)
    year = Date.utc_today.year()
    employees = Enum.sort_by employees, &(&1.last_name)
    render conn, "report.html", employees: employees, year: year
  end

  def load_thirteenth(conn, %{"year" => year}) do
    employees = Attendance.list_employees_post_dept_with_type(["regular", "probationary"])
    employees = Patt.Repo.preload(employees, :bonus)
    employees = Enum.sort_by employees, &(&1.last_name)
    year = String.to_integer(year)
    render conn, "report.html", employees: employees, year: year
  end

  def update_thirteenth(conn, %{"thirteenth" => params}) do
    {year, params} = Map.pop params, "year"
    year = String.to_integer(year)
    Enum.map params, fn {key, val} ->
      emp =
        Attendance.get_employee!(String.to_integer(key))
        |> Patt.Repo.preload(:bonus)
      bonus = Enum.find emp.bonus, fn b -> b.year.year == year end
      val =
      case Float.parse(val) do
        {val, _} -> val
        :error -> 0
      end
      IO.inspect bonus
      unless is_nil(bonus) do
        Payroll.update_bonus(bonus, %{thirteenth: val})
      else
        {:ok, date} = Date.new(year, 1, 1)
        Payroll.create_bonus(%{thirteenth: val, year: date, employee_id: emp.id})
      end
    end
    employees = Attendance.list_employees_post_dept_with_type(["regular", "probationary"])
    employees = Patt.Repo.preload(employees, :bonus)
    employees = Enum.sort_by employees, &(&1.last_name)
    render conn, "report.html", employees: employees, year: year
  end

  def emp_thirteenth(conn, %{"id" => id}) do
    employee = Attendance.get_employee! id
    employee = Map.put employee, :payslips, []
    totals = %{reg: 0.00, absent: 0.00, undertime: 0.00, tard: 0.00}
    render conn, "thirteenth.html", employee: employee, totals: totals
  end

  def gen_thirteenth(conn, %{"id" => id, "year" => year}) do
    #generate necessary information in order to calculate 13th month pay of employee
    employee = Attendance.get_employee! id
    {:ok, startd} = NaiveDateTime.new(String.to_integer(year), 1, 1, 0, 0, 0)
    {:ok, endd} = NaiveDateTime.new(String.to_integer(year), 12, 31, 0, 0, 0)
    query = from p in Payslip,  left_join: pr in assoc(p, :payperiod),
                                where: pr.from >= ^startd and pr.from <= ^endd,
                                order_by: pr.from
    employee = Patt.Repo.preload employee, [payslips: query]
    totalreg = Enum.reduce employee.payslips, 0, fn ps, acc -> acc + ps.regpay end
    totalabsent = Enum.reduce employee.payslips, 0, fn ps, acc -> acc + ps.absent end
    totalundertime = Enum.reduce employee.payslips, 0, fn ps, acc -> acc + ps.undertime end
    totaltardiness = Enum.reduce employee.payslips, 0, fn ps, acc -> acc + ps.tardiness end
    totals = %{reg: totalreg, absent: totalabsent, undertime: totalundertime, tard: totaltardiness}
    render conn, "thirteenth.html", employee: employee, totals: totals
  end

  def print_thirteenth(conn, %{"year" => year}) do
    employees =
      Attendance.list_employees_post_dept_with_type(["regular", "probationary"])
      |> Patt.Repo.preload(:bonus)
      |> Enum.sort_by(&(&1.last_name))
    conn
      |> put_layout(false)
      |> render("print_thirteenth.html", employees: employees, year: year)
  end
end
