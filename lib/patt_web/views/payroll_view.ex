defmodule PattWeb.PayrollView do
  require IEx
  use PattWeb, :view

  def put_zero(digit) do
    strdigit = Integer.to_string(digit)
    if String.length(strdigit) == 1 do
      "0" <> strdigit
    else
      strdigit
    end
  end

  def time_string(start, endt) do
    put_zero(start) <> ":" <> put_zero(endt)
  end

  def return_time_string(time) do
    if(time, do: time_string(time.hour, time.minute))
  end

  def return_date_and_day(date) do
    "#{date}" <> " | " <> Patt.Helper.return_day_string(Date.day_of_week(date))
  end

  def assoc_loaded?(data) do
    Ecto.assoc_loaded? data
  end

  def no_basic(basic) do
    is_nil(basic) || basic == 0 || basic == ""
  end

  def hide_ifnobasic(basic) do
    if(no_basic(basic), do: "hide", else: "")
  end
end
