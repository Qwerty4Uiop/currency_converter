defmodule CurrencyConverterWeb.PageControllerTest do
  use CurrencyConverterWeb.ConnCase

  import Mock

  alias CurrencyConverter.Cache
  alias CurrencyConverter.CbrApi
  alias CurrencyConverter.Conversion
  alias CurrencyConverter.Repo

  setup_with_mocks([{CbrApi, [], cbr_api_mock()}]) do
    Cache.clear()
    :ok
  end

  test "returns right conversion for existing currency", %{conn: conn} do
    conn = get(conn, "/convert", %{"amount" => "200", "currency" => "usd", "date" => "2021-03-31"})
    assert text_response(conn, 200) == "15127.46 RUB"
  end

  test "returns :rate_not_found for not existing rate", %{conn: conn} do
    conn = get(conn, "/convert", %{"amount" => "200", "currency" => "rub", "date" => "2021-03-31"})
    assert text_response(conn, 200) == ":rate_not_found"
  end

  test "returns :date_not_found for previous date that not exist in db", %{conn: conn} do
    conn = get(conn, "/convert", %{"amount" => "200", "currency" => "usd", "date" => "2021-03-30"})
    assert text_response(conn, 200) == ":date_not_found"
  end

  test "conversion correctly saved to db after request", %{conn: conn} do
    get(conn, "/convert", %{"amount" => "200", "currency" => "usd", "date" => "2021-03-31"})
    usd_rate = Decimal.from_float(75.6373)
    assert %{currency_iso: "USD", rate: ^usd_rate, date: ~D[2021-03-31]} = Repo.one(Conversion)
  end

  test "conversion correctly saved to ets after request", %{conn: conn} do
    get(conn, "/convert", %{"amount" => "200", "currency" => "usd", "date" => "2021-03-31"})
    assert Cache.get("USD_2021-03-31") == Decimal.from_float(75.6373)
  end

  test "request wasn't repeated for conversions with same currency and date", %{conn: conn} do
    conn = get(conn, "/convert", %{"amount" => "100", "currency" => "usd", "date" => "2021-03-31"})
    assert text_response(conn, 200) == "7563.73 RUB"
    conn = get(conn, "/convert", %{"amount" => "200", "currency" => "usd", "date" => "2021-03-31"})
    assert text_response(conn, 200) == "15127.46 RUB"
    conn = get(conn, "/convert", %{"amount" => "300", "currency" => "usd", "date" => "2021-03-31"})
    assert text_response(conn, 200) == "22691.19 RUB"
    conn = get(conn, "/convert", %{"amount" => "400", "currency" => "usd", "date" => "2021-03-31"})
    assert text_response(conn, 200) == "30254.92 RUB"
    conn = get(conn, "/convert", %{"amount" => "500", "currency" => "usd", "date" => "2021-03-31"})
    assert text_response(conn, 200) == "37818.65 RUB"

    assert_called_exactly CbrApi.request_rates(), 1
  end

  defp cbr_api_mock do
    [
      request_rates: fn ->
        {:ok,
         %{
           "Timestamp" => "2021-03-31T15:00:00+03:00",
           "Valute" => %{
             "USD" => %{
               "CharCode" => "USD",
               "ID" => "R01235",
               "Name" => "Доллар США",
               "Nominal" => 1,
               "NumCode" => "840",
               "Previous" => 75.7023,
               "Value" => 75.6373
             }
           }
         }}
      end
    ]
  end
end
