defmodule BankApi.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias BankApi.Repo

  alias BankApi.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def all do
    Repo.all(Transaction)
    |> create_payload()
  end

  @doc """
  Returns the list of transactions by year.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def year(year) do
    filter_query(Date.from_erl!({year, 01, 01}), Date.from_erl!({year, 12, 31}))
  end

  @doc """
  Returns the list of transactions by month.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def month(year, month) do
    start_date = Date.from_erl!({year, month, 01})
    days_in_month = start_date |> Date.days_in_month()
    end_date = Date.from_erl!({year, month, days_in_month})

    filter_query(start_date, end_date)
  end

  def filter_query(start_date, end_date) do
    query = from t in Transaction, where: t.date >= ^start_date and t.date <= ^end_date

    Repo.all(query)
    |> create_payload()
  end

  @doc """
  Returns the list of transactions by day.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def day(day) do
    query = from t in Transaction, where: t.date == ^Date.from_iso8601!(day)

    Repo.all(query)
    |> create_payload()
  end

  def create_payload(transactions) do
    %{
      transactions: transactions,
      total: calculate_value(transactions)
    }
  end

  def calculate_value(transactions) do
    Enum.reduce(transactions, Decimal.new("0"), fn t, acc ->
      Decimal.add(acc, t.value)
    end)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
