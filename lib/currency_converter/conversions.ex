defmodule CurrencyConverter.Conversions do
  alias CurrencyConverter.Conversion
  alias CurrencyConverter.Repo

  @spec find_conversion(binary, Date.t()) :: Conversion.t() | nil
  def find_conversion(currency_iso, date),
    do: Repo.get_by(Conversion, currency_iso: currency_iso, date: date)

  @spec get_rate(binary, Date.t()) :: Decimal.t() | {:error, :rate_not_found}
  def get_rate(currency_iso, date) do
    case find_conversion(currency_iso, date) do
      nil -> {:error, :rate_not_found}
      %{rate: rate} -> rate
    end
  end

  @spec insert(map) :: {:ok, Conversion.t()} | {:error, Ecto.Changeset.t()}
  def insert(attrs) do
    attrs
    |> Conversion.changeset()
    |> Repo.insert()
  end
end
