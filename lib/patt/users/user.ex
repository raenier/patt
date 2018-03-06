defmodule Patt.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Users.User


  schema "users" do
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :password_hash])
    |> validate_required([:username, :password_hash])
    |> unique_constraint(:username)
  end
end
