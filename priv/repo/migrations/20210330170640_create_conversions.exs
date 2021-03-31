defmodule CurrencyConverter.Repo.Migrations.CreateConversions do
  use Ecto.Migration

  def change do
    create table(:conversions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:currency_iso, :string)
      add(:date, :date)
      add(:rate, :decimal)

      timestamps()
    end

    create(unique_index(:conversions, [:currency_iso, :date]))
  end
end
