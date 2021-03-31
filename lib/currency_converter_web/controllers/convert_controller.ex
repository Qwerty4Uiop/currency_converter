defmodule CurrencyConverterWeb.ConvertController do
  use CurrencyConverterWeb, :controller

  def convert(conn, params) do
    with {number_amount, _rest} <- Float.parse(params["amount"]),
         formatted_currency = String.upcase(params["currency"]),
         parsed_date = Date.from_iso8601!(params["date"]),
         {:ok, result} <-
           CurrencyConverter.convert(number_amount, formatted_currency, parsed_date) do
      text(conn, "#{result} RUB")
    else
      {:error, error} -> text(conn, inspect(error))
      error -> text(conn, inspect(error))
    end
  end
end
