defmodule BudgieWeb.BudgetLive.Create do
  use BudgieWeb, :live_view

  alias Budgie.Tracking
  alias Budgie.Tracking.Budget

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header class="text-center">
        Budgets
        <:subtitle>Create a new budget</:subtitle>
      </.header>
      <.form for={@form} class="card bg-base-200 px-6 py-4" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:name]}
          label="Budget name"
          placeholder="e.g., Groceries, Entertainment, etc."
          autofocus
          required
        />
        <.input
          field={@form[:description]}
          label="Description"
          placeholder="What is this budget for?"
          type="textarea"
        />
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:end_date]} type="date" label="End date" />
        <div class="pt-4">
          <.button variant="primary" phx-disable-with="Creating...">Create budget</.button>
        </div>
      </.form>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    form = to_form(Tracking.change_budget(%Budget{}))
    socket = assign(socket, form: form)
    {:ok, socket}
  end

  def handle_event("validate", %{"budget" => params}, socket) do
    changeset =
      Tracking.change_budget(%Budget{}, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"budget" => params}, socket) do
    params = Map.put(params, "creator_id", socket.assigns.current_scope.user.id)

    case Tracking.create_budget(params) do
      {:ok, %Budget{}} ->
        socket =
          socket
          |> put_flash(:info, "Budget created successfully")
          |> redirect(to: ~p"/budgets")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
