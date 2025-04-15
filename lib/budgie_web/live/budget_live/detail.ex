defmodule BudgieWeb.BudgetLive.Detail do
  use BudgieWeb, :live_view

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header class="text-center">
        <p>{@budget.name}</p>
        <:subtitle>
          Manage your transactions.
        </:subtitle>
        <:actions>
          <.button navigate={~p"/budgets/#{@budget}/transactions/create"}>New transaction</.button>
        </:actions>
      </.header>
      <div class="flex flex-row gap-4">
        <% funding = Map.get(@summary, :funding, Decimal.new(0)) %>
        <% spending = Map.get(@summary, :spending, Decimal.new(0)) %>
        <% balance = Decimal.sub(funding, spending) %>
        <div class="card bg-base-200 flex-1">
          <div class="card-body">
            <div class="text-gray-400">Funding</div>
            <div class="text-2xl">
              <.currency amount={funding} />
            </div>
          </div>
        </div>
        <div class="card bg-base-200 flex-1">
          <div class="card-body">
            <div class="text-gray-400">Spending</div>
            <div class="text-2xl">
              <.currency amount={Decimal.negate(spending)} />
            </div>
          </div>
        </div>
        <div class="card bg-base-200 flex-1 ">
          <div class="card-body">
            <div class="text-gray-400">Balance</div>
            <div class="text-2xl">
              <.currency amount={balance} />
            </div>
          </div>
        </div>
      </div>
      <.table id="transactions" rows={@transactions}>
        <:col :let={transaction} label="Description">{transaction.description}</:col>
        <:col :let={transaction} label="Date">{transaction.effective_date}</:col>
        <:col :let={transaction} label="Amount">
          <.transaction_amount transaction={transaction} />
        </:col>
      </.table>
    </Layouts.app>
    """
  end

  def mount(%{"budget_id" => id}, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id, user: socket.assigns.current_scope.user, preload: [:creator])

    if budget do
      transactions = Tracking.list_transactions(budget)
      summary = Tracking.summarise_budget_transactions(budget)
      {:ok, assign(socket, budget: budget, transactions: transactions, summary: summary)}
    else
      socket =
        socket
        |> put_flash(:error, "Budget not found")
        |> redirect(to: ~p"/budgets")

      {:ok, socket}
    end
  end

  def mount(_invalid_id, _session, socket) do
    socket =
      socket
      |> put_flash(:error, "Budget not found")
      |> redirect(to: ~p"/budgets")

    {:ok, socket}
  end

  @doc """
  Renders a transaction amount as a currency value, considering the type of the transaction.

  ## Example

  <.transaction_amount transaction={%BudgetTransaction{type: :spending, amount: Decimal.new("24.05")}} />

  Output:
  <span class="tabular-nums text-red-500">-24.05</span>
  """

  attr :transaction, BudgetTransaction, required: true

  def transaction_amount(%{transaction: %{type: :spending, amount: amount}}),
    do: currency(%{amount: Decimal.negate(amount)})

  def transaction_amount(%{transaction: %{type: :funding, amount: amount}}),
    do: currency(%{amount: amount})

  @doc """
  Renders a currency amount field.

  ## Example

  <.currency amount={Decimal.new("246.01")} />

  Output:
  <span class="tabular-nums text-green-500">246.01</span>
  """
  attr :amount, Decimal, required: true
  attr :class, :string, default: nil
  attr :positive_class, :string, default: "text-green-500"
  attr :negative_class, :string, default: "text-red-500"

  def currency(assigns) do
    ~H"""
    <span class={[
      "tabular-nums",
      Decimal.gte?(@amount, 0) && @positive_class,
      Decimal.lt?(@amount, 0) && @negative_class,
      @class
    ]}>
      {Decimal.round(@amount, 2)}
    </span>
    """
  end
end
