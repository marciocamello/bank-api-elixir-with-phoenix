defmodule BankApi.Operations do
  alias BankApi.Accounts
  alias BankApi.Accounts.Account
  alias BankApi.Repo

  def transfer(from_id, to_id, value) do
    from = Accounts.get!(from_id)
    value = Decimal.new(value)

    case is_negative?(from.balance, value) do
      true -> {:error, "You have negative balance"}
      false -> perform_update(from, to_id, value)
    end
  end

  defp is_negative?(from_balance, value) do
    Decimal.sub(from_balance, value)
    |> Decimal.negative?()
  end

  def perform_update(from, to_id, value) do
    {:ok, from} =perform_operation(from, value, :sub)
    {:ok, to} = Accounts.get!(to_id)
    |> perform_operation(value, :sum)
    {:ok, "Successful transfer!! from #{from.id} to: #{to.id} value: #{value}"}
  end

  def perform_operation(account, value, :sub) do
    account
    |> update_account(%{balance: Decimal.sub(account.balance, value)})
  end

  def perform_operation(account, value, :sum) do
    account
    |> update_account(%{balance: Decimal.add(account.balance, value)})
  end

  def update_account(%Account{} = account, attrs) do
    Account.changeset(account, attrs)
    |> Repo.update()
  end

end
