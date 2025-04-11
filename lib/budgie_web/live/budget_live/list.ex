defmodule BudgieWeb.BudgetLive.List do
  use BudgieWeb, :live_view

  import BudgieWeb.CoreComponents

  alias Budgie.Tracking

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header class="text-center">
        <p>Budgets</p>
        <:subtitle>
          Manage your budgets.
        </:subtitle>
        <:actions>
          <.button navigate={~p"/budgets/create"}>New budget</.button>
        </:actions>
      </.header>
      <.table id="budgets" rows={@budgets}>
        <:col :let={budget} label="Name">{budget.name}</:col>
        <:col :let={budget} label="Name">{budget.name}</:col>
        <:col :let={budget} label="Start date">{budget.start_date}</:col>
        <:col :let={budget} label="End date">{budget.end_date}</:col>
      </.table>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    budgets = Tracking.list_budgets(user: socket.assigns.current_scope.user)
    socket = assign(socket, budgets: budgets)
    {:ok, socket}
  end
end
