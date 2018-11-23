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
  alias Patt.Payroll
  alias Patt.Attendance

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
    |> Repo.preload(payslips: [:payperiod, employee: [:compensation]])
  end

  def create_payperiod(attrs \\ %{}) do
    %Payperiod{}
    |> Payperiod.changeset(attrs)
    |> Repo.insert()
  end

  #custom
  def daytype_list(employee, year) do
    all_dtypes =
      %Patt.Payroll.Daytype{}
        |> Map.pop(:__struct__)
        |> elem(1)
        |> Enum.sort_by(&(elem(&1, 1).order))
        |> Keyword.keys

    used_leaves = Payroll.used_leave(employee, year)
    all_dtypes =
    Enum.map all_dtypes, fn key ->
      unless employee.emp_type == "probationary" do
        cond do
          key == :vl ->
            if used_leaves.rem_vl <= 0 do
              [key: String.upcase(Atom.to_string(key)), value: key, disabled: true]
            else
              [key: String.upcase(Atom.to_string(key)), value: key]
            end

          key == :sl ->
            if used_leaves.rem_sl <= 0 do
              [key: String.upcase(Atom.to_string(key)), value: key, disabled: true]
            else
              [key: String.upcase(Atom.to_string(key)), value: key]
            end

          true ->
            [key: String.upcase(Atom.to_string(key)), value: key]
        end
      else
        cond do
          key == :vl ->
            [key: String.upcase(Atom.to_string(key)), value: key, disabled: true]

          key == :sl ->
            [key: String.upcase(Atom.to_string(key)), value: key, disabled: true]

          true ->
            [key: String.upcase(Atom.to_string(key)), value: key]
        end
      end
    end
  end

  def used_leave(employee, year) do
    {:ok, start} = Date.from_erl {year, 01, 01}
    {:ok, endd} = Date.from_erl {year, 12, 31}

    %{
      rem_sl: employee.leave.sl_total - used_sl(employee, start, endd),
      rem_vl: employee.leave.vl_total - used_vl(employee, start, endd),
    }
  end

  def used_vl(employee, start_date, end_date) do
    from(d in Patt.Attendance.Dtr, where: d.daytype == "vl" and d.employee_id == ^employee.id and d.date >= ^start_date and d.date <= ^end_date)
    |> Patt.Repo.all
    |> Enum.count
  end

  def used_sl(employee, start_date, end_date) do
    from(d in Patt.Attendance.Dtr, where: d.daytype == "sl" and d.employee_id == ^employee.id and d.date >= ^start_date and d.date <= ^end_date)
    |> Patt.Repo.all
    |> Enum.count
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
    case employee.compensation.paymode do
      "daily" ->
        ((employee.compensation.basic / employee.employee_sched.dpm)/8/60)

      "365" ->
        ((employee.compensation.basic * 12)/365)/8/60

      "313" ->
        ((employee.compensation.basic * 12)/313)/8/60

      "261" ->
        ((employee.compensation.basic * 12)/261)/8/60

      _ ->
        ((employee.compensation.basic / employee.employee_sched.dpm)/8/60)
    end
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
      dtr = Patt.Repo.preload(dtr, :employee)
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
                Map.put(acc, :hopay, acc.hopay + (dtr.hw * (minuterate * %Patt.Payroll.Rates{}.reghord.daily)))
              else
                Map.put(acc, :hopay, acc.hopay)
              end
            else
              #ERROR on no schedule
              if dtr.in && dtr.out do
                Map.put(acc, :hopay, acc.hopay + (dtr.hw * (minuterate * %Patt.Payroll.Rates{}.regho.daily)))
              else
                Map.put(acc, :hopay, acc.hopay)
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
                #TODO Error on nil dtr.hw
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

  def get_user_inputs(
    sss_loan, pagibig_loan, office_loan, bank_loan, healthcare,
    other_pay, fel, others, otherpay_remarks, otherded_remarks
  ) do

    sss_loan = unless String.trim(sss_loan) == "", do: String.to_integer(sss_loan), else: 0
    pagibig_loan = unless String.trim(pagibig_loan) == "", do: String.to_integer(pagibig_loan), else: 0
    office_loan = unless String.trim(office_loan) == "", do: String.to_integer(office_loan), else: 0
    bank_loan = unless String.trim(bank_loan) == "", do: String.to_integer(bank_loan), else: 0
    healthcare = unless String.trim(healthcare) == "", do: String.to_integer(healthcare), else: 0
    other_pay =
      unless String.trim(other_pay) == "" do
        {val, _rem} = Float.parse(other_pay)
        val
      else
        0
      end
    otherpay_remarks = unless String.trim(otherpay_remarks) == "", do: otherpay_remarks
    fel = unless String.trim(fel) == "", do: String.to_integer(fel), else: 0
    others =
      unless String.trim(others) == ""  do
        {val, _rem} = Float.parse(others)
        val
      else
        0
      end
    otherded_remarks = unless String.trim(otherded_remarks) == "", do: otherded_remarks

    %{sss_loan: sss_loan,
      pagibig_loan: pagibig_loan,
      office_loan: office_loan,
      bank_loan: bank_loan,
      healthcare: healthcare,
      other_pay: other_pay,
      otherpay_remarks: otherpay_remarks,
      fel: fel,
      others: others,
      otherded_remarks: otherded_remarks,
    }
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

    %{rdpay: rdpay, hopay: hopay} =
      if payslip.employee.emp_class == "rnf" do
        compute_hoandrdpay(dtrs, minuterate)
      else
        %{rdpay: 0, hopay: 0}
      end
    vlpay = totals.vl * minuterate
    slpay = totals.sl * minuterate

    #Allowances
    rice = unless is_nil(compen.rice), do: compen.rice/2, else: 0
    communication = unless is_nil(compen.communication), do: compen.communication/2, else: 0
    meal = unless is_nil(compen.meal), do: compen.meal/2, else: 0
    transpo = unless is_nil(compen.transpo), do: compen.transpo/2, else: 0
    gasoline = unless is_nil(compen.gasoline), do: compen.gasoline/2, else: 0
    clothing = unless is_nil(compen.clothing), do: compen.clothing/2, else: 0

    total_allowance = rice + communication + meal + transpo + gasoline + clothing
    total_leavepay = vlpay + slpay
    #########

    regpay =
      case compen.paymode do
        "daily" ->
          (totals.totalwm * minuterate)

        "365" ->
          compen.basic/2 - total_leavepay

        "313" ->
          compen.basic/2 - total_leavepay

        "261" ->
          compen.basic/2 - total_leavepay

         _ ->
          (totals.totalwm * minuterate)
      end

    #case: if rnf compute else if spv or mgr dont
    overtime =
      if payslip.employee.emp_class == "rnf" do
        compute_overtime_perday(dtrs, minuterate)
      else
        0
      end

    philhealth =
      if payslip.employee.contribution.check_philhealth do
        compute_philhealth(compen.basic)
      else
        0
      end

    pagibig =
      if payslip.employee.contribution.check_pagibig do
        compute_pagibig()
      else
        0
      end

    sss =
      if payslip.employee.contribution.check_sss do
        compute_sss(compen.basic)
      else
        0
      end

    absent = compute_absent(totals.totalabs, minuterate)
    undertime = compute_undertime(totals.ut, minuterate)
    tardiness = (totals.tard * minuterate)

    gross = vlpay + slpay + regpay + overtime + hopay + rdpay + userinputs.other_pay + total_allowance
    deduction = sss + pagibig + philhealth + absent + tardiness + undertime

    #TAX
    #Compute also for fringe benefits excess
    #total compensation - deduction
    net_taxable = gross - deduction
    taxshielded = net_taxable - (net_taxable * 0.3) #taxshield 30%
    #wtax = compute_wtax(taxshielded)
    wtax = 0

    otherdeductions =
      userinputs.sss_loan + userinputs.pagibig_loan + userinputs.office_loan + userinputs.bank_loan + userinputs.healthcare + userinputs.fel + userinputs.others + wtax

    net = net_taxable - otherdeductions

    pschangeset = Payslip.changeset(payslip, %{
        regpay: regpay,
        vlpay: vlpay,
        slpay: slpay,
        otpay: overtime,
        rdpay: rdpay,
        hopay: hopay,
        other_pay: userinputs.other_pay,
        otherpay_remarks: userinputs.otherpay_remarks,
        rice: rice,
        communication: communication,
        meal: meal,
        transpo: transpo,
        gasoline: gasoline,
        clothing: clothing,
        tardiness: tardiness,
        undertime: undertime,
        absent: absent,
        pagibig: pagibig,
        philhealth: philhealth,
        sss: sss,
        wtax: wtax,
        sss_loan: userinputs.sss_loan,
        hdmf_loan: userinputs.pagibig_loan,
        office_loan: userinputs.office_loan,
        bank_loan: userinputs.bank_loan,
        healthcare: userinputs.healthcare,
        feliciana: userinputs.fel,
        other_deduction: userinputs.others,
        otherded_remarks: userinputs.otherded_remarks,
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

  def get_total_for_attribute(enumerable, attrib) do
    Enum.reduce enumerable, 0.0, fn(p, acc) ->
      attrval = Map.get(p, attrib)
      unless is_nil(attrval) do
        acc + attrval
      else
        acc
      end
    end
  end

  def summary_totals(payslips) do
    map =
      %{}
      |> Map.put(:totalreg, get_total_for_attribute(payslips, :regpay))
      |> Map.put(:totalot, get_total_for_attribute(payslips, :otpay))
      |> Map.put(:totalrd, get_total_for_attribute(payslips, :rdpay))
      |> Map.put(:totalsl, get_total_for_attribute(payslips, :slpay))
      |> Map.put(:totalvl, get_total_for_attribute(payslips, :vlay))
      |> Map.put(:totalho, get_total_for_attribute(payslips, :hopay))

      |> Map.put(:totalrice, get_total_for_attribute(payslips, :rice))
      |> Map.put(:totalcomm, get_total_for_attribute(payslips, :communication))
      |> Map.put(:totalmeal, get_total_for_attribute(payslips, :meal))
      |> Map.put(:totaltranspo, get_total_for_attribute(payslips, :transpo))
      |> Map.put(:totalgasoline, get_total_for_attribute(payslips, :gasoline))
      |> Map.put(:totalclothing, get_total_for_attribute(payslips, :clothing))

      |> Map.put(:totalop, get_total_for_attribute(payslips, :other_pay))
      |> Map.put(:totalgross, get_total_for_attribute(payslips, :totalcompen))
      |> Map.put(:totalsss, get_total_for_attribute(payslips, :sss))
      |> Map.put(:totalphilhealth, get_total_for_attribute(payslips, :philhealth))
      |> Map.put(:totalpagibig, get_total_for_attribute(payslips, :pagibig))
      |> Map.put(:totaltardiness, get_total_for_attribute(payslips, :tardiness))
      |> Map.put(:totalundertime, get_total_for_attribute(payslips, :undertime))
      |> Map.put(:totalabsences, get_total_for_attribute(payslips, :absent))
      |> Map.put(:totaltax, get_total_for_attribute(payslips, :wtax))
      |> Map.put(:totalhmo, get_total_for_attribute(payslips, :healthcare))

      |> Map.put(:totalsssloan, get_total_for_attribute(payslips, :sss_loan))
      |> Map.put(:totalpagibigloan, get_total_for_attribute(payslips, :hdmf_loan))
      |> Map.put(:totalofficeloan, get_total_for_attribute(payslips, :office_loan))

      |> Map.put(:totaldeductions, get_total_for_attribute(payslips, :totaldeduction))
      |> Map.put(:totalnet, get_total_for_attribute(payslips, :net))
      |> Map.put(:totalfel, get_total_for_attribute(payslips, :feliciana))
      |> Map.put(:totalbl, get_total_for_attribute(payslips, :bank_loan))
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
