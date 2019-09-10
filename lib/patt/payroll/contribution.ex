defmodule Patt.Payroll.Contribution do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Contribution
  alias Patt.Attendance.Employee


  schema "contributions" do
    field :pagibig, :string
    field :philhealth, :string
    field :sss, :string
    field :check_pagibig, :boolean
    field :check_philhealth, :boolean
    field :check_sss, :boolean

    belongs_to :employee, Employee

    timestamps()
  end

  @doc false
  def changeset(%Contribution{} = contribution, attrs) do
    contribution
    |> cast(attrs, [:sss, :pagibig, :philhealth, :check_pagibig, :check_philhealth, :check_sss,])
    |> validate_required([])
  end
end
