defmodule Patt.Payroll.Daytype do
  defstruct(
    regular:  %{daily: 1, ot: 1.3, order: 1},
    halfday:  %{daily: 1, ot: 1.3, order: 3},
    restday:     %{daily: 1, ot: 1.3, order: 5},
    vl:       %{daily: 1, ot: 1.3, order: 6},
    sl:       %{daily: 1, ot: 1.3, order: 7},
    ob:       %{daily: 1, ot: 1.3, order: 8},
    hopay:    %{daily: 1, ot: 1.3, order: 9},
    ndot:     %{daily: 1, ot: 1.3, order: 11}
  )
end
