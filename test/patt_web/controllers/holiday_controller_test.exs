defmodule PattWeb.HolidayControllerTest do
  use PattWeb.ConnCase

  alias Patt.Payroll

  @create_attrs %{date: ~D[2010-04-17], name: "some name", type: "some type"}
  @update_attrs %{date: ~D[2011-05-18], name: "some updated name", type: "some updated type"}
  @invalid_attrs %{date: nil, name: nil, type: nil}

  def fixture(:holiday) do
    {:ok, holiday} = Payroll.create_holiday(@create_attrs)
    holiday
  end

  describe "index" do
    test "lists all holidays", %{conn: conn} do
      conn = get conn, holiday_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Holidays"
    end
  end

  describe "new holiday" do
    test "renders form", %{conn: conn} do
      conn = get conn, holiday_path(conn, :new)
      assert html_response(conn, 200) =~ "New Holiday"
    end
  end

  describe "create holiday" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, holiday_path(conn, :create), holiday: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == holiday_path(conn, :show, id)

      conn = get conn, holiday_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Holiday"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, holiday_path(conn, :create), holiday: @invalid_attrs
      assert html_response(conn, 200) =~ "New Holiday"
    end
  end

  describe "edit holiday" do
    setup [:create_holiday]

    test "renders form for editing chosen holiday", %{conn: conn, holiday: holiday} do
      conn = get conn, holiday_path(conn, :edit, holiday)
      assert html_response(conn, 200) =~ "Edit Holiday"
    end
  end

  describe "update holiday" do
    setup [:create_holiday]

    test "redirects when data is valid", %{conn: conn, holiday: holiday} do
      conn = put conn, holiday_path(conn, :update, holiday), holiday: @update_attrs
      assert redirected_to(conn) == holiday_path(conn, :show, holiday)

      conn = get conn, holiday_path(conn, :show, holiday)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, holiday: holiday} do
      conn = put conn, holiday_path(conn, :update, holiday), holiday: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Holiday"
    end
  end

  describe "delete holiday" do
    setup [:create_holiday]

    test "deletes chosen holiday", %{conn: conn, holiday: holiday} do
      conn = delete conn, holiday_path(conn, :delete, holiday)
      assert redirected_to(conn) == holiday_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, holiday_path(conn, :show, holiday)
      end
    end
  end

  defp create_holiday(_) do
    holiday = fixture(:holiday)
    {:ok, holiday: holiday}
  end
end
