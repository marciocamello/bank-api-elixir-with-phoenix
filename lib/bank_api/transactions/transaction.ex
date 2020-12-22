defmodule BankApi.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "transactions" do
    field :value, :decimal
    field :account_from, :string
    field :account_to, :string
    field :type, :string
    field :date, :date

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :value,
      :account_from,
      :account_to,
      :type,
      :date
    ])
    |> validate_required([
      :value,
      :account_from,
      :account_to,
      :type,
      :date
    ])
  end
end
