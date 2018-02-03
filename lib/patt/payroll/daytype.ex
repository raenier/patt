defmodule Patt.Payroll.Daytype do
  defstruct(
    regular:  %{daily: 1, ot: 1.3, order: 1},
    halfday:  %{daily: 1, ot: 1.3, order: 2},
    ot:       %{daily: 1, ot: 1.3, order: 3},
    rdot:     %{daily: 1, ot: 1.3, order: 4},
    vl:       %{daily: 1, ot: 1.3, order: 5},
    sl:       %{daily: 1, ot: 1.3, order: 6},
    ob:       %{daily: 1, ot: 1.3, order: 7},
    hopay:    %{daily: 1, ot: 1.3, order: 8},
    hoot:     %{daily: 1, ot: 1.3, order: 9},
    ndot:     %{daily: 1, ot: 1.3, order: 10}
  )
end
