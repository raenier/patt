defmodule Patt.Payroll.HolidayType do
  defstruct(
    regular:    %{daily: 1, ot: 1.3, rdot: 0},
    special:  %{daily: 0.3, ot: 1.3, rdot: 0},
  )
end
