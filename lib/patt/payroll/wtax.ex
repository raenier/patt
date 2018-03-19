defmodule Patt.Payroll.Wtax do
  defstruct(
    range1: %{range: 1..10416, base: 0, overcl: 0},
    range2: %{range: 10417..16666, base: 0, overcl: 0.20},
    range3: %{range: 16667..33332, base: 1250, overcl: 0.25},
    range4: %{range: 33333..83332, base: 5416.67, overcl: 0.30},
    range5: %{range: 83333..333332, base: 20416.67, overcl: 0.32},
    range6: %{range: 333333..1000000, base: 100416.67, overcl: 0.35},
  )
end
