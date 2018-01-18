defmodule Patt.Payroll.Daytype do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Daytype


  schema "daytypes" do
    field :rate, :integer
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(%Daytype{} = daytype, attrs) do
    daytype
    |> cast(attrs, [:type, :rate])
    |> validate_required([:type, :rate])
  end
end
