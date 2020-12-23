defmodule BankApi.Operations do
  alias BankApi.Accounts
  alias BankApi.Accounts.Account
  alias BankApi.Repo
  alias BankApi.Transactions.Transaction
  alias Ecto.Multi

  @withdraw "withdraw"
  @transfer "transfer"

  def transfer(from_id, to_id, value) do
    from = Accounts.get!(from_id)
    value = Decimal.new(value)

    operation_case(from.balance, value, perform_update(from, to_id, value))
  end

  def withdraw(from_id, value) do
    from = Accounts.get!(from_id)
    value = Decimal.new(value)

    operation_case(from.balance, value, withdraw_operation(from, value))
  end

  defp operation_case(balance, value, operation) do
    case is_negative?(balance, value) do
      true ->
        {:error, "You cant't have negative balance!"}

      false ->
        operation
    end
  end

  defp withdraw_operation(from, value) do
    Multi.new()
    |> Multi.update(:account_from, perform_operation(from, value, :sub))
    |> Multi.insert(:transaction, gen_transaction(value, from.id, nil, @withdraw))
    |> Repo.transaction()
    |> transaction_case("Successful withdraw! from #{from.id} value: #{value}")
  end

  defp is_negative?(from_balance, value) do
    Decimal.sub(from_balance, value)
    |> Decimal.negative?()
  end

  def perform_update(from, to_id, value) do
    to = Accounts.get!(to_id)

    Multi.new()
    |> Multi.update(:account_from, perform_operation(from, value, :sub))
    |> Multi.update(:account_to, perform_operation(to, value, :sum))
    |> Multi.insert(:transaction, gen_transaction(value, from.id, to.id, @transfer))
    |> Repo.transaction()
    |> transaction_case("Successful transfer! from #{from.id} to: #{to.id} value: #{value}")
  end

  def perform_operation(account, value, :sub) do
    account
    |> update_account(%{balance: Decimal.sub(account.balance, value)})
  end

  def perform_operation(account, value, :sum) do
    account
    |> update_account(%{balance: Decimal.add(account.balance, value)})
  end

  defp transaction_case(operations, msg) do
    case operations do
      {:ok, _} ->
        {:ok, msg}

      {:error, :account_from, changeset, _} ->
        {:error, changeset}

      {:error, :account_to, changeset, _} ->
        {:error, changeset}

      {:error, :transaction, changeset, _} ->
        {:error, changeset}
    end
  end

  def update_account(%Account{} = account, attrs) do
    Account.changeset(account, attrs)
  end

  defp gen_transaction(value, from_id, to_id, type) do
    %Transaction{
      value: value,
      account_from: from_id,
      account_to: to_id,
      type: type,
      date: Date.utc_today()
    }
  end
end
