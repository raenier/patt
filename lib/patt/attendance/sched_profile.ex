defmodule Patt.Attendance.SchedProfile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.SchedProfile


  schema "sched_profiles" do
    field :name, :string
    field :time_in, :time
    field :time_out, :time

    timestamps()
  end

  @doc false
  def changeset(%SchedProfile{} = sched_profile, attrs) do
    sched_profile
    |> cast(attrs, [:name, :time_in, :time_out])
    |> validate_required([:name, :time_in, :time_out])
  end
end
