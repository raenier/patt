defmodule Patt.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
    create constraint(:users, :username_is_required, check: "char_length(username) > 0")
    create constraint(:users, :password_hash_is_required, check: "char_length(password_hash) > 0")
  end
end
