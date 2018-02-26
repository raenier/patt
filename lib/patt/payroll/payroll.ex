defmodule Patt.Payroll do
  @moduledoc """
  The Payroll context.
  """

  import Ecto.Query, warn: false
  alias Patt.Repo

  alias Patt.Payroll.Contribution
  alias Patt.Payroll.Payperiod
  alias Patt.Payroll.Payslip
  alias Patt.Payroll.Holiday

  def list_contributions do
    Repo.all(Contribution)
  end

  def get_contribution!(id), do: Repo.get!(Contribution, id)

  def create_contribution(attrs \\ %{}) do
    %Contribution{}
    |> Contribution.changeset(attrs)
    |> Repo.insert()
  end

  def update_contribution(%Contribution{} = contribution, attrs) do
    contribution
    |> Contribution.changeset(attrs)
    |> Repo.update()
  end

  def delete_contribution(%Contribution{} = contribution) do
    Repo.delete(contribution)
  end

  def change_contribution(%Contribution{} = contribution) do
    Contribution.changeset(contribution, %{})
  end

  #payperiod
  def get_all_payperiod() do
    Repo.all Payperiod
  end

  def get_else_create_payperiod(from, to) do
    payperiod = get_specific_payperiod(from, to)
    unless is_nil(payperiod) || Enum.empty?(payperiod) do
      List.first payperiod
    else
      {:ok, payperiod} = create_payperiod(%{from: from, to: to})
      payperiod
    end
  end

  def get_specific_payperiod(from, to) do
    from(pp in Payperiod, where: pp.from == ^from and pp.to == ^to)
    |> Repo.all()
  end

  def create_payperiod(attrs \\ %{}) do
    %Payperiod{}
    |> Payperiod.changeset(attrs)
    |> Repo.insert()
  end

  #custom
  def daytype_list(employee) do
    all_dtypes =
      %Patt.Payroll.Daytype{}
        |> Map.pop(:__struct__)
        |> elem(1)
        |> Enum.sort_by(&(elem(&1, 1).order))
        |> Keyword.keys

    all_dtypes =
      if employee.leave.sl_total == 0 do
        Enum.filter(all_dtypes, &(&1 !== :sl))
      else
        all_dtypes
      end

    all_dtypes =
      if employee.leave.vl_total == 0 do
        Enum.filter(all_dtypes, &(&1 !== :vl))
      else
        all_dtypes
      end

    Enum.map all_dtypes, fn daytype ->
      {String.upcase(Atom.to_string(daytype)), daytype}
    end
  end

  def used_leave(employee) do
    {:ok, start} = Date.from_erl {Date.utc_today.year, 01, 01}
    {:ok, endd} = Date.from_erl {Date.utc_today.year, 12, 31}
    used_sl =
      from(d in Patt.Attendance.Dtr, where: d.daytype == "sl" and d.employee_id == ^employee.id and d.date >= ^start and d.date <= ^endd)
      |> Patt.Repo.all
      |> Enum.count

    used_vl =
      from(d in Patt.Attendance.Dtr, where: d.daytype == "vl" and d.employee_id == ^employee.id and d.date >= ^start and d.date <= ^endd)
      |> Patt.Repo.all
      |> Enum.count

    %{
      rem_sl: employee.leave.sl_total - used_sl,
      rem_vl: employee.leave.vl_total - used_vl,
    }
  end

  ###PAYSLIP
  def list_payslips do
    Repo.all(Payslip)
  end

  def get_payslip!(id), do: Repo.get!(Payslip, id)

  def get_specific_payslip(employee_id, payperiod_id) do
    from(ps in Payslip, where: ps.employee_id == ^employee_id and ps.payperiod_id == ^payperiod_id )
    |> Repo.all()
  end

  def get_ps_else_new(employee_id, payperiod_id) do
    payslip = get_specific_payslip(employee_id, payperiod_id)
    unless is_nil(payslip) || Enum.empty?(payslip) do
      List.first(payslip)
    else
      %Payslip{employee_id: employee_id, payperiod_id: payperiod_id}
    end
  end

  def create_payslip(attrs \\ %{}) do
    %Payslip{}
    |> Payslip.changeset(attrs)
    |> Repo.insert()
  end

  def update_payslip(%Payslip{} = payslip, attrs) do
    payslip
    |> Payslip.changeset(attrs)
    |> Repo.update()
  end

  def delete_payslip(%Payslip{} = payslip) do
    Repo.delete(payslip)
  end

  def change_payslip(%Payslip{} = payslip) do
    Payslip.changeset(payslip, %{})
  end

  def minute_rate(employee) do
    employee = Repo.preload(employee, [:compensation, :employee_sched])
    ((employee.compensation.basic / employee.employee_sched.dpm)/8/60)
  end

  def compute_payslip(payslip, totals) do
    payslip = Repo.preload(payslip, employee: [:compensation])

  def compute_other_deductions(loan, fel, others) do
    loan = unless String.trim(loan) == "", do: String.to_integer(loan), else: 0
    fel = unless String.trim(fel) == "", do: String.to_integer(fel), else: 0
    others = unless String.trim(others) == "", do: String.to_integer(others), else: 0
    %{loan: loan, fel: fel, others: others}
  end

    minuterate = minute_rate(payslip.employee)

    vlpay = totals.vl * minuterate
    slpay = totals.sl * minuterate

    #anticipate daytypes when computing,
    #hopay consider hollidaytypes when computing, legal special - create table
    #edit compensation include allowance on editing of employee info - constant. divide by two or by number of days present

    #undertime and absent are different computations
    #consider tardiness rule for computing tardiness, subtract halfday/4hrs when late of > 30 minutes
    #edit payslip add totaldays of work and absent days

    pschangeset = Payslip.changeset(payslip, %{
        regpay: (totals.totalwm * minuterate) - (vlpay + slpay),
        vlpay: vlpay,
        slpay: slpay,
        otpay: totals.ot * (minuterate * 1.25),
        hopay: 0,
        allowance: 0,
        tardiness: 0,
        undertime: 0,
        absent: 0,
        wtax: 0,
        loan: userinputs.loan,
        feliciana: userinputs.fel,
        other_deduction: userinputs.others,
      })
    if payslip.id do
      Repo.update(pschangeset)
    else
      Repo.insert(pschangeset)
    end
  end

  def minute_rate() do
    #compute minute rate
  end

  ###HOLIDAYS
  #
  def list_holidays do
    {:ok, start} = Date.new(Date.utc_today().year, 01, 01)
    {:ok, endd} = Date.new(Date.utc_today().year, 12, 31)

    from(h in Holiday, where: h.date >= ^start and h.date <= ^endd)
    |> Repo.all()
  end

  def list_holidays_date() do
    holidays = list_holidays()
    Enum.map holidays, &(&1.date)
  end

  def get_holiday!(id), do: Repo.get!(Holiday, id)

  def create_holiday(attrs \\ %{}) do
    %Holiday{}
    |> Holiday.changeset(attrs)
    |> Repo.insert()
  end

  def update_holiday(%Holiday{} = holiday, attrs) do
    holiday
    |> Holiday.changeset(attrs)
    |> Repo.update()
  end

  def delete_holiday(%Holiday{} = holiday) do
    Repo.delete(holiday)
  end

  def change_holiday(%Holiday{} = holiday) do
    Holiday.changeset(holiday, %{})
  end
end
