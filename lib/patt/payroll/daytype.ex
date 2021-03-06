defmodule Patt.Payroll.Daytype do
  defstruct(
    regular:  %{daily: 1, ot: 1.3, order: 1},
    halfday:  %{daily: 1, ot: 1.3, order: 3},
    restday:  %{daily: 1, ot: 1.3, order: 5},
    vl:       %{daily: 1, ot: 1.3, order: 6},
    sl:       %{daily: 1, ot: 1.3, order: 7},
    absent:   %{daily: 1, ot: 1.3, order: 8},
    lwop:     %{daily: 1, ot: 1.3, order: 9},
    ob:       %{daily: 1, ot: 1.3, order: 10},
  )
end
