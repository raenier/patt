defmodule Patt.Payroll.Rates do
  defstruct(
    regular:    %{daily: 0,     ot: 1.25},
    restday:    %{daily: 1.30,  ot: 1.69},
    special:    %{daily: 0.30,  ot: 1.69},
    specialrd:  %{daily: 1.50,  ot: 1.95},

    regho:      %{daily: 1,     ot: 2.60},
    reghord:    %{daily: 2.60,  ot: 3.38},
  )
end
