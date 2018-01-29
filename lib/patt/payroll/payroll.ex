defmodule Patt.Payroll do
  @moduledoc """
  The Payroll context.
  """

  import Ecto.Query, warn: false
  alias Patt.Repo

  alias Patt.Payroll.Contribution

  @doc """
  Returns the list of contributions.

  ## Examples

      iex> list_contributions()
      [%Contribution{}, ...]

  """
  def list_contributions do
    Repo.all(Contribution)
  end

  @doc """
  Gets a single contribution.

  Raises `Ecto.NoResultsError` if the Contribution does not exist.

  ## Examples

      iex> get_contribution!(123)
      %Contribution{}

      iex> get_contribution!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contribution!(id), do: Repo.get!(Contribution, id)

  @doc """
  Creates a contribution.

  ## Examples

      iex> create_contribution(%{field: value})
      {:ok, %Contribution{}}

      iex> create_contribution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contribution(attrs \\ %{}) do
    %Contribution{}
    |> Contribution.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contribution.

  ## Examples

      iex> update_contribution(contribution, %{field: new_value})
      {:ok, %Contribution{}}

      iex> update_contribution(contribution, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contribution(%Contribution{} = contribution, attrs) do
    contribution
    |> Contribution.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Contribution.

  ## Examples

      iex> delete_contribution(contribution)
      {:ok, %Contribution{}}

      iex> delete_contribution(contribution)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contribution(%Contribution{} = contribution) do
    Repo.delete(contribution)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contribution changes.

  ## Examples

      iex> change_contribution(contribution)
      %Ecto.Changeset{source: %Contribution{}}

  """
  def change_contribution(%Contribution{} = contribution) do
    Contribution.changeset(contribution, %{})
  end

  #custom

  def daytype_list() do
    [
      "Regular": "reg",
      "OT": "ot",
      "RD-OT": "rdot",
      "VL": "vl",
      "SL": "sl",
      "BL": "bl",
      "OB": "ob",
      "HO-Pay": "ho",
      "HO-OT": "hoot",
      "ND-OT": "ndot"
    ]
  end

end
