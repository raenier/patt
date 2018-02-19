defmodule Patt.Payroll do
  @moduledoc """
  The Payroll context.
  """

  import Ecto.Query, warn: false
  alias Patt.Repo

  alias Patt.Payroll.Contribution
  alias Patt.Payroll.Payperiod
  alias Patt.Payroll.Payslip

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

    #hide vl and sl option when probationary or sl/vl_total is 0
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
end
