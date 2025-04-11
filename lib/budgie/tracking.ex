defmodule Budgie.Tracking do
  @moduledoc """
  Context module for tracking-related functionality.
  """
  import Ecto.Query

  alias Budgie.Repo
  alias Budgie.Tracking.Budget

  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end

  def list_budgets, do: Repo.all(Budget)

  def list_budgets(criteria) when is_list(criteria) do
    query = from(b in Budget)

    Enum.reduce(criteria, query, fn
      {:user, user}, query ->
        from b in query, where: b.creator_id == ^user.id

      {:preload, bindings}, query ->
        preload(query, ^bindings)

      _, query ->
        query
    end)
    |> Repo.all()
  end

  def get_budget!(id), do: Repo.get!(Budget, id)

  def change_budget(budget, attrs \\ %{}) do
    Budget.changeset(budget, attrs)
  end
end
