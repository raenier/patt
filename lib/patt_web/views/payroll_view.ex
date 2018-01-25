defmodule PattWeb.PayrollView do
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

  def assoc_loaded?(data) do
    Ecto.assoc_loaded? data
  end
end
