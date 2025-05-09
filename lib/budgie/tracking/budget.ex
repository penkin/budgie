defmodule Budgie.Tracking.Budget do
  @moduledoc """
  Defines the Budget schema and related changeset functions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budgets" do
    field :name, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date

    belongs_to :creator, Budgie.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:name, :description, :start_date, :end_date, :creator_id])
    |> validate_required([:name, :description, :start_date, :end_date, :creator_id])
    |> validate_length(:name, max: 100)
    |> validate_length(:description, max: 500)
    |> check_constraint(:end_date,
      name: :budget_end_after_start,
      message: "must be after start date"
    )
  end
end
