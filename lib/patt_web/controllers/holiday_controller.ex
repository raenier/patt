defmodule PattWeb.HolidayController do
  use PattWeb, :controller

  alias Patt.Payroll
  alias Patt.Payroll.Holiday

  def index(conn, _params) do
    holidays = Payroll.list_holidays()
    holidays = Enum.sort_by(holidays, &(Date.to_erl(&1.date)))
    render(conn, "index.html", holidays: holidays)
  end

  def new(conn, _params) do
    changeset = Payroll.change_holiday(%Holiday{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"holiday" => holiday_params}) do
    case Payroll.create_holiday(holiday_params) do
      {:ok, holiday} ->
        conn
        |> put_flash(:info, "Holiday created successfully.")
        |> redirect(to: holiday_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    holiday = Payroll.get_holiday!(id)
    render(conn, "show.html", holiday: holiday)
  end

  def edit(conn, %{"id" => id}) do
    holiday = Payroll.get_holiday!(id)
    changeset = Payroll.change_holiday(holiday)
    render(conn, "edit.html", holiday: holiday, changeset: changeset)
  end

  def update(conn, %{"id" => id, "holiday" => holiday_params}) do
    holiday = Payroll.get_holiday!(id)

    case Payroll.update_holiday(holiday, holiday_params) do
      {:ok, holiday} ->
        conn
        |> put_flash(:info, "Holiday updated successfully.")
        |> redirect(to: holiday_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", holiday: holiday, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    holiday = Payroll.get_holiday!(id)
    {:ok, _holiday} = Payroll.delete_holiday(holiday)

    conn
    |> put_flash(:info, "Holiday deleted successfully.")
    |> redirect(to: holiday_path(conn, :index))
  end
end
