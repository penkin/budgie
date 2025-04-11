defmodule BudgieWeb.BudgetLive.CreateTest do
  use BudgieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Budgie.AccountsFixtures

  @invalid_attrs %{
    name: nil,
    description: nil,
    start_date: nil,
    end_date: nil
  }

  setup %{conn: conn} do
    user = user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  describe "Create budget" do
    test "renders form", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/budgets/create")

      assert has_element?(lv, "input[name='budget[name]']")
      assert has_element?(lv, "textarea[name='budget[description]']")
      assert has_element?(lv, "input[name='budget[start_date]']")
      assert has_element?(lv, "input[name='budget[end_date]']")
    end

    test "validates form", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/budgets/create")

      lv
      |> form("form", budget: @invalid_attrs)
      |> render_change()

      assert has_element?(lv, "form", "can't be blank")
    end

    test "creates budget with valid data", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/budgets/create")

      attrs = %{
        name: "Test Budget",
        description: "Test Description",
        start_date: ~D[2024-01-01],
        end_date: ~D[2024-12-31]
      }

      lv
      |> form("form", budget: attrs)
      |> render_submit()

      assert_redirected(lv, ~p"/budgets")

      # Verify the budget was created
      assert [budget] = Budgie.Tracking.list_budgets()
      assert budget.name == "Test Budget"
      assert budget.description == "Test Description"
      assert budget.creator_id == user.id
    end

    test "handles invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/budgets/create")

      lv
      |> form("form", budget: @invalid_attrs)
      |> render_submit()

      assert has_element?(lv, "form", "can't be blank")
    end
  end
end
