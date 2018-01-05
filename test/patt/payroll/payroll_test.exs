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
end
