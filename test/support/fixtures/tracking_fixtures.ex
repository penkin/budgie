defmodule Budgie.TrackingFixtures do
  @moduledoc """
  Test fixtures for tracking-related functionality.
  """

  alias Budgie.Tracking

  def valid_budget_attributes(attrs \\ %{}) do
    attrs
    |> add_creator_if_necessary()
    |> Enum.into(%{
      name: "Test Budget",
      description: "Test description.",
      start_date: ~D[2025-01-01],
      end_date: ~D[2025-01-31]
    })
  end

  def budget_fixture(attrs \\ %{}) do
    {:ok, budget} =
      attrs
      |> valid_budget_attributes()
      |> Tracking.create_budget()

    budget
  end

  def add_creator_if_necessary(attrs) do
    Map.put_new_lazy(attrs, :creator_id, fn -> Budgie.AccountsFixtures.user_fixture().id end)
  end
end
