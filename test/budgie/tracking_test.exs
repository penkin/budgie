defmodule Budgie.TrackingTest do
  @moduledoc """
  Tests for tracking-related functionality.
  """
  use Budgie.DataCase

  import Budgie.TrackingFixtures

  alias Budgie.Tracking

  describe "create_budget/1" do
    test "with valid attributes" do
      attrs = valid_budget_attributes()

      assert {:ok, budget} = Tracking.create_budget(attrs)
      assert budget.name == "Test Budget"
      assert budget.description == "Test description."
      assert budget.start_date == ~D[2025-01-01]
      assert budget.end_date == ~D[2025-01-31]
    end
  end

  describe "create_budget/1 with invalid attributes" do
    test "with missing required fields" do
      attrs = %{
        name: nil,
        description: nil,
        start_date: nil,
        end_date: nil,
        creator_id: nil
      }

      assert {:error, changeset} = Tracking.create_budget(attrs)
      assert changeset.valid? == false
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).description
      assert "can't be blank" in errors_on(changeset).start_date
      assert "can't be blank" in errors_on(changeset).end_date
      assert "can't be blank" in errors_on(changeset).creator_id
    end
  end

  describe "create_budget/1 with invalid date range" do
    test "with end date before start date" do
      attrs =
        valid_budget_attributes()
        |> Map.merge(%{
          start_date: ~D[2025-01-31],
          end_date: ~D[2025-01-01]
        })

      assert {:error, changeset} = Tracking.create_budget(attrs)
      assert changeset.valid? == false
      assert "must be after start date" in errors_on(changeset).end_date
    end
  end
end
