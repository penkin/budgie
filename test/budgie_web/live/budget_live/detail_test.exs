defmodule BudgieWeb.BudgetLive.DetailTest do
  alias Budgie.AccountsFixtures
  use BudgieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Budgie.AccountsFixtures
  import Budgie.TrackingFixtures

  setup do
    user = user_fixture()
    budget = budget_fixture(%{creator_id: user.id})
    %{user: user, budget: budget}
  end

  describe "Show budget" do
    test "shows budget when it exists", %{conn: conn, user: user, budget: budget} do
      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets/#{budget}")

      assert html =~ budget.name
    end

    test "redirects to list page when budget does not exist", %{conn: conn, user: user} do
      fake_id = Ecto.UUID.generate()
      conn = log_in_user(conn, user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{fake_id}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Budget not found"} = conn.assigns.flash
    end

    test "redirects to list page when budget is hidden from the user", %{
      conn: conn,
      budget: budget
    } do
      other_user = AccountsFixtures.user_fixture()
      conn = log_in_user(conn, other_user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{budget}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Budget not found"} = conn.assigns.flash
    end

    test "redirects to list page when budget id is invalid", %{
      conn: conn,
      user: user
    } do
      conn = log_in_user(conn, user)

      {:ok, conn} =
        live(conn, ~p"/budgets/invalid")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Budget not found"} = conn.assigns.flash
    end
  end
end
