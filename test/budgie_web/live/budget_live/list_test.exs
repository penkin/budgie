defmodule BudgieWeb.BudgetLive.ListTest do
  use BudgieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Budgie.AccountsFixtures
  import Budgie.TrackingFixtures

  setup do
    user = user_fixture()
    %{user: user}
  end

  describe "List view" do
    test "shows budget when one exists", %{conn: conn, user: user} do
      budget = budget_fixture(%{creator_id: user.id})

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets")

      assert html =~ budget.name
    end
  end
end
