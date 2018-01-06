defmodule Patt.Payroll.Tax do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Payroll.Tax


  schema "taxes" do
    field :tin, :integer
    field :wtax, :integer
    field :employee_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Tax{} = tax, attrs) do
    tax
    |> cast(attrs, [:tin, :wtax])
    |> validate_required([])
  end
end
