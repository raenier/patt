defmodule Patt.Payroll.Holiday do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Holiday


  schema "holidays" do
    field :date, :date
    field :name, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(%Holiday{} = holiday, attrs) do
    holiday
    |> cast(attrs, [:name, :type, :date])
    |> validate_required([:name, :type, :date])
    |> unsafe_validate_unique(:date, Patt.Repo)
  end
end
