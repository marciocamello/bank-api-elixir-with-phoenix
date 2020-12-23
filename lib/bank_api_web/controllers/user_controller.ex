defmodule BankApiWeb.UserController do
  use BankApiWeb, :controller
  alias BankApi.Accounts
  alias BankApi.Repo

  action_fallback BankApiWeb.FallbackController

  def signup(conn, %{"user" => user}) do
    with {:ok, user, account} <- Accounts.create_user(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, id: user.id))
      |> render("account.json", %{user: user, account: account})
    end
  end

  def signin(conn, %{"email" => email, "password" => password}) do
    user = Repo.get!(Accounts.User, "92dd2862-ab9f-430a-bff2-76473154eff4")
    |> Repo.preload(:accounts)
    render(conn, "user_auth.json", user: user, token: "123")
  end

  def index(conn, _) do
    conn
    |> render("index.json", users: Accounts.get_users())
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    conn
    |> render("show.json", user: user)
  end
end
