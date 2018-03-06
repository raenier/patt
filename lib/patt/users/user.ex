defmodule Patt.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Patt.Users.User


  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> hash_password
    |> unique_constraint(:username)
  end

  defp hash_password(%Ecto.Changeset{
    valid?: true,
    changes: %{password: password}
  } = changeset) when byte_size(password) > 0 do
    change(changeset, Comeonin.Bcrypt.add_hash(password))
  end
  defp hash_password(changeset), do: changeset

  def update_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> hash_password
    |> unique_constraint(:username)
  end
end
