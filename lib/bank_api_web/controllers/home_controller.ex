defmodule BankApiWeb.HomeController do
  use BankApiWeb, :controller

  def index(conn, params) do
    json(conn, %{message: "BankAPI"})
  end
end
