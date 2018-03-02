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

  def get_payperiod_payslip!(id) do
    Payperiod
    |> Repo.get!(id)
    |> Repo.preload(payslips: [:employee, :payperiod])
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

  def compute_absent(absentminutes, mrate) do
    unless is_nil(absentminutes) || absentminutes == 0 || absentminutes == "" do
      absentminutes * mrate
    else
      0
    end
  end

  def compute_undertime(utminutes, mrate) do
    unless is_nil(utminutes) || utminutes == 0 || utminutes == "" do
      utminutes * mrate
    else
      0
    end
  end

  def compute_overtime_perday(dtrs, minuterate) do
    Enum.reduce dtrs, 0, fn(dtr, acc) ->
      if dtr.ot && Patt.Attendance.all_inputs_complete(dtr) do
        ho = get_holiday_bydate(dtr.date)
        if is_nil(ho) do
          if dtr.daytype == "restday" do
            acc + ((%Patt.Payroll.Rates{}.restday.ot * minuterate) * dtr.overtime)
          else
            acc + ((%Patt.Payroll.Rates{}.regular.ot * minuterate) * dtr.overtime)
          end
        else
          case ho.type do
            "special" ->
                  if dtr.daytype == "restday" do
                    acc + ((%Patt.Payroll.Rates{}.specialrd.ot * minuterate) * dtr.overtime)
                  else
                    acc + ((%Patt.Payroll.Rates{}.special.ot * minuterate) * dtr.overtime)
                  end

            "regular" ->
                  if dtr.daytype == "restday" do
                    acc + ((%Patt.Payroll.Rates{}.reghord.ot * minuterate) * dtr.overtime)
                  else
                    acc + ((%Patt.Payroll.Rates{}.regho.ot * minuterate) * dtr.overtime)
                  end
          end
        end
      else
        acc
      end
    end
  end

  def compute_hoandrdpay(dtrs, minuterate) do
    Enum.reduce dtrs, %{rdpay: 0, hopay: 0}, fn dtr, acc ->
      ho = get_holiday_bydate(dtr.date)
      if is_nil(ho) do
        if dtr.daytype == "restday" do
          if dtr.in && dtr.out do
            Map.put(acc, :rdpay, acc.rdpay + (dtr.hw * (minuterate * %Patt.Payroll.Rates{}.restday.daily)))
          else
            Map.put(acc, :rdpay, acc.rdpay)
            Map.put(acc, :hopay, acc.hopay)
          end
        else
            Map.put(acc, :rdpay, acc.rdpay)
            Map.put(acc, :hopay, acc.hopay)
        end
      else
        case ho.type do
          "regular" ->
            if dtr.daytype == "restday" do
              if dtr.in && dtr.out do
                Map.put(acc, :hopay, acc.hopay + ((480 * minuterate) + (dtr.hw * (minuterate * %Patt.Payroll.Rates{}.reghord.daily))))
              else
                Map.put(acc, :hopay, acc.hopay + (480 * minuterate))
              end
            else
              if dtr.in && dtr.out do
                Map.put(acc, :hopay, acc.hopay + ((480 * minuterate) + (dtr.hw * (minuterate * %Patt.Payroll.Rates{}.regho.daily))))
              else
                Map.put(acc, :hopay, acc.hopay + (480 * minuterate))
              end
            end

          "special"->
            if dtr.daytype == "restday" do
              if dtr.in && dtr.out do
                Map.put(acc, :hopay, acc.hopay + (dtr.hw * (minuterate * %Patt.Payroll.Rates{}.specialrd.daily)))
              else
                Map.put(acc, :rdpay, acc.rdpay)
                Map.put(acc, :hopay, acc.hopay)
              end
            else
              if dtr.in && dtr.out do
                Map.put(acc, :hopay, acc.hopay + (dtr.hw * (minuterate * %Patt.Payroll.Rates{}.special.daily)))
              else
                Map.put(acc, :rdpay, acc.rdpay)
                Map.put(acc, :hopay, acc.hopay)
              end
            end
        end
      end

    end
  end

  def compute_other_deductions(loan, fel, others) do
    loan = unless String.trim(loan) == "", do: String.to_integer(loan), else: 0
    fel = unless String.trim(fel) == "", do: String.to_integer(fel), else: 0
    others = unless String.trim(others) == "", do: String.to_integer(others), else: 0
    %{loan: loan, fel: fel, others: others}
  end

  def compute_pagibig() do
    50
  end

  def compute_philhealth(basic) do
    cond do
      (basic <= 10000) ->
        (275/2)/2

      (basic > 10000 and basic < 40000) ->
        ((basic * 0.0275)/2)/2

      (basic >= 40000) ->
        (1100/2)/2
    end
  end

  def compute_sss(basic) do
    {_, sss_table} = Map.pop %Patt.Payroll.SSS{}, :__struct__
    keys = Map.keys(sss_table)
    contrib =
      Enum.reduce keys, 0, fn (key, acc) ->
        if basic in sss_table[key].range do
          sss_table[key].contrib + acc
        else
          acc
        end
      end
    contrib/2
  end

  def compute_wtax(taxable) do
    {_, tax_table} = Map.pop %Patt.Payroll.Wtax{}, :__struct__
    keys = Map.keys(tax_table)
    wtax =
    Enum.reduce keys, 0, fn(key, acc) ->
      if round(taxable) in tax_table[key].range do
        overcl = taxable - tax_table[key].range.first
        acc + tax_table[key].base + (overcl * tax_table[key].overcl)
      else
        acc
      end
    end

    wtax/2
  end

  def compute_payslip(payslip, totals, userinputs, dtrs) do
    payslip = Repo.preload(payslip, employee: [:compensation, :contribution])
    minuterate = minute_rate(payslip.employee)
    compen = payslip.employee.compensation

    %{rdpay: rdpay, hopay: hopay} = compute_hoandrdpay(dtrs, minuterate)
    vlpay = totals.vl * minuterate
    slpay = totals.sl * minuterate
    nontaxable_allowance = unless is_nil(compen.allowance_ntaxable), do: compen.allowance_ntaxable/2, else: 0
    taxable_allowance = unless is_nil(compen.allowance_taxable), do: compen.allowance_taxable/2, else: 0
    regpay = (totals.totalwm * minuterate)
    overtime = compute_overtime_perday(dtrs, minuterate)

    philhealth =
      if payslip.employee.contribution.philhealth_num do
        compute_philhealth(compen.basic)
      else
        0
      end

    pagibig =
      if payslip.employee.contribution.pagibig_num do
        compute_pagibig()
      else
        0
      end

    sss =
      if payslip.employee.contribution.sss_num do
        compute_sss(compen.basic)
      else
        0
      end

    absent = compute_absent(totals.totalabs, minuterate)
    undertime = compute_undertime(totals.ut, minuterate)
    tardiness = (totals.tard * minuterate)

    #consider tardiness rule for computing tardiness, subtract halfday/4hrs when late of > 30 minutes

    gross = vlpay + slpay + regpay + overtime + taxable_allowance + hopay + rdpay
    deduction = sss + pagibig + philhealth + absent + tardiness + undertime

    #total compensation - deduction
    net_taxable = gross - deduction
    taxshielded = net_taxable - (net_taxable * 0.3) #taxshield 30%
    wtax = compute_wtax(taxshielded)

    otherdeductions = userinputs.loan + userinputs.fel + userinputs.others + wtax

    net = net_taxable + nontaxable_allowance - otherdeductions

    pschangeset = Payslip.changeset(payslip, %{
        regpay: regpay,
        vlpay: vlpay,
        slpay: slpay,
        otpay: overtime,
        rdpay: rdpay,
        hopay: hopay,
        ntallowance: nontaxable_allowance,
        tallowance: taxable_allowance,
        tardiness: tardiness,
        undertime: undertime,
        absent: absent,
        pagibig: pagibig,
        philhealth: philhealth,
        sss: sss,
        wtax: wtax,
        loan: userinputs.loan,
        feliciana: userinputs.fel,
        other_deduction: userinputs.others,
        totalcompen: gross,
        totaldeduction: deduction,
        net_taxable: net_taxable,
        net: net,
      })
    if payslip.id do
      Repo.update(pschangeset)
    else
      Repo.insert(pschangeset)
    end
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

  def get_holiday_bydate(date) do
    Repo.get_by(Holiday, date: date)
  end

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
