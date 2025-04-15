defmodule BudgieWeb.BudgetLive.TransactionCreate do
  use BudgieWeb, :live_view

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header class="text-center">
        Budgets
        <:subtitle>Create transaction</:subtitle>
      </.header>
      <.form for={@form} class="card bg-base-200 px-6 py-4" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:type]}
          label="Transaction type"
          type="select"
          options={[Spending: "spending", Funding: "funding"]}
        />
        <.input
          field={@form[:amount]}
          label="Amount"
          placeholder="R123.45"
          type="number"
          step="0.01"
          autofocus
          required
        />
        <.input
          field={@form[:description]}
          label="Description"
          placeholder="What is this transaction for?"
          type="textarea"
        />
        <.input field={@form[:effective_date]} type="date" label="Effective date" />
        <div class="pt-4">
          <.button variant="primary" phx-disable-with="Creating...">Create transaction</.button>
        </div>
      </.form>
    </Layouts.app>
    """
  end

  def mount(%{"budget_id" => budget_id}, _session, socket) do
    form = to_form(Tracking.change_budget_transaction(default_transaction()))
    socket = assign(socket, form: form, budget_id: budget_id)
    {:ok, socket}
  end

  def handle_event("validate", %{"budget_transaction" => params}, socket) do
    changeset =
      Tracking.change_budget_transaction(%BudgetTransaction{}, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"budget_transaction" => params}, socket) do
    params = Map.put(params, "budget_id", socket.assigns.budget_id)

    case Tracking.create_budget_transaction(params) do
      {:ok, %BudgetTransaction{}} ->
        socket =
          socket
          |> put_flash(:info, "Transaction created successfully")
          |> redirect(to: ~p"/budgets/#{socket.assigns.budget_id}")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp default_transaction do
    %BudgetTransaction{effective_date: Date.utc_today()}
  end
end
