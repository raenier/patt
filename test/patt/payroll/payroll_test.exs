defmodule Patt.PayrollTest do
  use Patt.DataCase

  alias Patt.Payroll

  describe "contributions" do
    alias Patt.Payroll.Contribution

    @valid_attrs %{pagibig_con: 42, pagibig_num: 42, philhealth_con: 42, philhealth_num: 42, sss_con: 42, sss_num: 42}
    @update_attrs %{pagibig_con: 43, pagibig_num: 43, philhealth_con: 43, philhealth_num: 43, sss_con: 43, sss_num: 43}
    @invalid_attrs %{pagibig_con: nil, pagibig_num: nil, philhealth_con: nil, philhealth_num: nil, sss_con: nil, sss_num: nil}

    def contribution_fixture(attrs \\ %{}) do
      {:ok, contribution} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payroll.create_contribution()

      contribution
    end

    test "list_contributions/0 returns all contributions" do
      contribution = contribution_fixture()
      assert Payroll.list_contributions() == [contribution]
    end

    test "get_contribution!/1 returns the contribution with given id" do
      contribution = contribution_fixture()
      assert Payroll.get_contribution!(contribution.id) == contribution
    end

    test "create_contribution/1 with valid data creates a contribution" do
      assert {:ok, %Contribution{} = contribution} = Payroll.create_contribution(@valid_attrs)
      assert contribution.pagibig_con == 42
      assert contribution.pagibig_num == 42
      assert contribution.philhealth_con == 42
      assert contribution.philhealth_num == 42
      assert contribution.sss_con == 42
      assert contribution.sss_num == 42
    end

    test "create_contribution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payroll.create_contribution(@invalid_attrs)
    end

    test "update_contribution/2 with valid data updates the contribution" do
      contribution = contribution_fixture()
      assert {:ok, contribution} = Payroll.update_contribution(contribution, @update_attrs)
      assert %Contribution{} = contribution
      assert contribution.pagibig_con == 43
      assert contribution.pagibig_num == 43
      assert contribution.philhealth_con == 43
      assert contribution.philhealth_num == 43
      assert contribution.sss_con == 43
      assert contribution.sss_num == 43
    end

    test "update_contribution/2 with invalid data returns error changeset" do
      contribution = contribution_fixture()
      assert {:error, %Ecto.Changeset{}} = Payroll.update_contribution(contribution, @invalid_attrs)
      assert contribution == Payroll.get_contribution!(contribution.id)
    end

    test "delete_contribution/1 deletes the contribution" do
      contribution = contribution_fixture()
      assert {:ok, %Contribution{}} = Payroll.delete_contribution(contribution)
      assert_raise Ecto.NoResultsError, fn -> Payroll.get_contribution!(contribution.id) end
    end

    test "change_contribution/1 returns a contribution changeset" do
      contribution = contribution_fixture()
      assert %Ecto.Changeset{} = Payroll.change_contribution(contribution)
    end
  end

  describe "payslips" do
    alias Patt.Payroll.Payslip

    @valid_attrs %{gross: 42, leavepay: 42, net: 42, otpay: 42, pagibig: 42, philhealth: 42, regpay: 42, sss: 42, tardiness: 42, undertime: 42}
    @update_attrs %{gross: 43, leavepay: 43, net: 43, otpay: 43, pagibig: 43, philhealth: 43, regpay: 43, sss: 43, tardiness: 43, undertime: 43}
    @invalid_attrs %{gross: nil, leavepay: nil, net: nil, otpay: nil, pagibig: nil, philhealth: nil, regpay: nil, sss: nil, tardiness: nil, undertime: nil}

    def payslip_fixture(attrs \\ %{}) do
      {:ok, payslip} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payroll.create_payslip()

      payslip
    end

    test "list_payslips/0 returns all payslips" do
      payslip = payslip_fixture()
      assert Payroll.list_payslips() == [payslip]
    end

    test "get_payslip!/1 returns the payslip with given id" do
      payslip = payslip_fixture()
      assert Payroll.get_payslip!(payslip.id) == payslip
    end

    test "create_payslip/1 with valid data creates a payslip" do
      assert {:ok, %Payslip{} = payslip} = Payroll.create_payslip(@valid_attrs)
      assert payslip.gross == 42
      assert payslip.leavepay == 42
      assert payslip.net == 42
      assert payslip.otpay == 42
      assert payslip.pagibig == 42
      assert payslip.philhealth == 42
      assert payslip.regpay == 42
      assert payslip.sss == 42
      assert payslip.tardiness == 42
      assert payslip.undertime == 42
    end

    test "create_payslip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payroll.create_payslip(@invalid_attrs)
    end

    test "update_payslip/2 with valid data updates the payslip" do
      payslip = payslip_fixture()
      assert {:ok, payslip} = Payroll.update_payslip(payslip, @update_attrs)
      assert %Payslip{} = payslip
      assert payslip.gross == 43
      assert payslip.leavepay == 43
      assert payslip.net == 43
      assert payslip.otpay == 43
      assert payslip.pagibig == 43
      assert payslip.philhealth == 43
      assert payslip.regpay == 43
      assert payslip.sss == 43
      assert payslip.tardiness == 43
      assert payslip.undertime == 43
    end

    test "update_payslip/2 with invalid data returns error changeset" do
      payslip = payslip_fixture()
      assert {:error, %Ecto.Changeset{}} = Payroll.update_payslip(payslip, @invalid_attrs)
      assert payslip == Payroll.get_payslip!(payslip.id)
    end

    test "delete_payslip/1 deletes the payslip" do
      payslip = payslip_fixture()
      assert {:ok, %Payslip{}} = Payroll.delete_payslip(payslip)
      assert_raise Ecto.NoResultsError, fn -> Payroll.get_payslip!(payslip.id) end
    end

    test "change_payslip/1 returns a payslip changeset" do
      payslip = payslip_fixture()
      assert %Ecto.Changeset{} = Payroll.change_payslip(payslip)
    end
  end

  describe "holidays" do
    alias Patt.Payroll.Holiday

    @valid_attrs %{date: ~D[2010-04-17], name: "some name", type: "some type"}
    @update_attrs %{date: ~D[2011-05-18], name: "some updated name", type: "some updated type"}
    @invalid_attrs %{date: nil, name: nil, type: nil}

    def holiday_fixture(attrs \\ %{}) do
      {:ok, holiday} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payroll.create_holiday()

      holiday
    end

    test "list_holidays/0 returns all holidays" do
      holiday = holiday_fixture()
      assert Payroll.list_holidays() == [holiday]
    end

    test "get_holiday!/1 returns the holiday with given id" do
      holiday = holiday_fixture()
      assert Payroll.get_holiday!(holiday.id) == holiday
    end

    test "create_holiday/1 with valid data creates a holiday" do
      assert {:ok, %Holiday{} = holiday} = Payroll.create_holiday(@valid_attrs)
      assert holiday.date == ~D[2010-04-17]
      assert holiday.name == "some name"
      assert holiday.type == "some type"
    end

    test "create_holiday/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payroll.create_holiday(@invalid_attrs)
    end

    test "update_holiday/2 with valid data updates the holiday" do
      holiday = holiday_fixture()
      assert {:ok, holiday} = Payroll.update_holiday(holiday, @update_attrs)
      assert %Holiday{} = holiday
      assert holiday.date == ~D[2011-05-18]
      assert holiday.name == "some updated name"
      assert holiday.type == "some updated type"
    end

    test "update_holiday/2 with invalid data returns error changeset" do
      holiday = holiday_fixture()
      assert {:error, %Ecto.Changeset{}} = Payroll.update_holiday(holiday, @invalid_attrs)
      assert holiday == Payroll.get_holiday!(holiday.id)
    end

    test "delete_holiday/1 deletes the holiday" do
      holiday = holiday_fixture()
      assert {:ok, %Holiday{}} = Payroll.delete_holiday(holiday)
      assert_raise Ecto.NoResultsError, fn -> Payroll.get_holiday!(holiday.id) end
    end

    test "change_holiday/1 returns a holiday changeset" do
      holiday = holiday_fixture()
      assert %Ecto.Changeset{} = Payroll.change_holiday(holiday)
    end
  end

  describe "bonus" do
    alias Patt.Payroll.Bonus

    @valid_attrs %{thirteenth: 120.5}
    @update_attrs %{thirteenth: 456.7}
    @invalid_attrs %{thirteenth: nil}

    def bonus_fixture(attrs \\ %{}) do
      {:ok, bonus} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payroll.create_bonus()

      bonus
    end

    test "list_bonus/0 returns all bonus" do
      bonus = bonus_fixture()
      assert Payroll.list_bonus() == [bonus]
    end

    test "get_bonus!/1 returns the bonus with given id" do
      bonus = bonus_fixture()
      assert Payroll.get_bonus!(bonus.id) == bonus
    end

    test "create_bonus/1 with valid data creates a bonus" do
      assert {:ok, %Bonus{} = bonus} = Payroll.create_bonus(@valid_attrs)
      assert bonus.thirteenth == 120.5
    end

    test "create_bonus/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payroll.create_bonus(@invalid_attrs)
    end

    test "update_bonus/2 with valid data updates the bonus" do
      bonus = bonus_fixture()
      assert {:ok, bonus} = Payroll.update_bonus(bonus, @update_attrs)
      assert %Bonus{} = bonus
      assert bonus.thirteenth == 456.7
    end

    test "update_bonus/2 with invalid data returns error changeset" do
      bonus = bonus_fixture()
      assert {:error, %Ecto.Changeset{}} = Payroll.update_bonus(bonus, @invalid_attrs)
      assert bonus == Payroll.get_bonus!(bonus.id)
    end

    test "delete_bonus/1 deletes the bonus" do
      bonus = bonus_fixture()
      assert {:ok, %Bonus{}} = Payroll.delete_bonus(bonus)
      assert_raise Ecto.NoResultsError, fn -> Payroll.get_bonus!(bonus.id) end
    end

    test "change_bonus/1 returns a bonus changeset" do
      bonus = bonus_fixture()
      assert %Ecto.Changeset{} = Payroll.change_bonus(bonus)
    end
  end
end
