defmodule CurrencyConverter.CbrApi do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.cbr-xml-daily.ru"
  plug Tesla.Middleware.JSON, decode_content_types: ["application/javascript; charset=utf-8"]

  @spec request_rates :: {:ok, map} | {:error, :request_rates_error}
  def request_rates do
    case get("/daily_json.js") do
      {:ok, %{status: status, body: rates}} when status >= 200 and status < 300 -> {:ok, rates}
      _ -> {:error, :request_rates_error}
    end
  end
end
