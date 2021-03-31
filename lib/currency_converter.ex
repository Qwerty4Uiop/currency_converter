defmodule CurrencyConverter do
  alias CurrencyConverter.Cache
  alias CurrencyConverter.Conversions
  alias CurrencyConverter.CbrApi

  @spec convert(amount :: float(), currency_iso :: String.t(), date :: Date.t()) ::
          {:ok, float()} | {:error, atom()}
  def convert(amount, currency_iso, date) do
    with {:ok, rate} <- get_rate(currency_iso, date) do
      {:ok, amount |> Decimal.from_float() |> Decimal.mult(rate) |> Decimal.to_float()}
    end
  end

  defp get_rate(currency_iso, date) do
    case get_existing_rate(currency_iso, date) do
      {:error, :rate_not_found} -> request_rate(currency_iso, date)
      rate -> {:ok, rate}
    end
  end

  defp get_existing_rate(currency_iso, date) do
    case Cache.get("#{currency_iso}_#{Timex.format!(date, "{YYYY}-{0M}-{D}")}") do
      nil -> Conversions.get_rate(currency_iso, date)
      rate -> rate
    end
  end

  defp request_rate(currency_iso, date) do
    with {:ok, rates} <- CbrApi.request_rates(),
         :ok <- check_date(rates, date),
         {:ok, rate} <- extract_rate(rates, currency_iso),
         {:ok, _} <- Conversions.insert(%{currency_iso: currency_iso, date: date, rate: rate}),
         :ok <- Cache.put("#{currency_iso}_#{Timex.format!(date, "{YYYY}-{0M}-{D}")}", rate) do
      {:ok, rate}
    end
  end

  defp extract_rate(rates, currency_iso) do
    case rates["Valute"][currency_iso]["Value"] do
      nil -> {:error, :rate_not_found}
      rate -> {:ok, Decimal.from_float(rate)}
    end
  end

  defp check_date(%{"Timestamp" => timestamp}, date) do
    timestamp
    |> Timex.parse!("{ISO:Extended}")
    |> Timex.to_date()
    |> Timex.equal?(date)
    |> case do
      true -> :ok
      false -> {:error, :date_not_found}
    end
  end

  defp check_date(_rates, _date), do: {:error, :incorrect_rates_date}
end
