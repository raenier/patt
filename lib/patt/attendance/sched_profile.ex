defmodule Patt.Attendance.SchedProfile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Attendance.SchedProfile


  schema "sched_profiles" do
    field :name, :string
    field :morning_in, :time
    field :morning_out, :time
    field :afternoon_in, :time
    field :afternoon_out, :time

    timestamps()
  end

  @doc false
  def changeset(%SchedProfile{} = sched_profile, attrs) do
    sched_profile
    |> cast(attrs, [:name, :morning_in, :morning_out, :afternoon_in, :afternoon_out])
    |> validate_required([:morning_in, :afternoon_out])
  end
end
