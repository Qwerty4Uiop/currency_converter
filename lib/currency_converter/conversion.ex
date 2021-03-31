defmodule CurrencyConverter.Conversion do
  use CurrencyConverter.Model

  schema "conversions" do
    field :currency_iso, :string
    field :date, :date
    field :rate, :decimal

    timestamps()
  end

  @fields [:currency_iso, :date, :rate]
  def changeset(conversion \\ %Conversion{}, attrs) do
    conversion
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:currency_iso, :date])
  end
end
