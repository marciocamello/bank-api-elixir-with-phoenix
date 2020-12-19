defmodule BankApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :role, :string, default: "user"

    has_one :accounts, BankApi.Accounts.Account
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :first_name,
      :last_name,
      :password,
      :password_confirmation,
      :role
    ])
    |> validate_required([
      :email,
      :first_name,
      :last_name,
      :password,
      :password_confirmation,
      :role
    ])
    |> validate_format(:email, ~r/@/, message: "Invalid email format")
    |> update_change(:email, &String.downcase(&1))
    |> validate_length(:password,
      min: 6,
      max: 100,
      message: "Password min is 6 characters and max 100 characters"
    )
    |> validate_confirmation(:password, message: "Password don't match")
    |> unique_constraint(:email, message: "This has exist in our system")
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp hash_password(changeset) do
    changeset
  end
end
