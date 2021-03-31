defmodule CurrencyConverter.Cache do
  use GenServer

  @ttl 3 * 1000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: ConversionsCache)
  end

  def init(state) do
    create_table()
    {:ok, state}
  end

  def put(key, data) do
    GenServer.cast(ConversionsCache, {:put, key, data})
  end

  def get(key) do
    GenServer.call(ConversionsCache, {:get, key})
  end

  def delete(key) do
    GenServer.cast(ConversionsCache, {:delete, key})
  end

  def clear do
    GenServer.cast(ConversionsCache, :clear)
  end

  def handle_call({:get, key}, _from, state) do
    reply =
      case :ets.lookup(:conversions_cache, key) do
        [] -> nil
        [{_key, conversion}] -> conversion
      end

    {:reply, reply, state}
  end

  def handle_cast({:delete, key}, state) do
    :ets.delete(:conversions_cache, key)
    {:noreply, state}
  end

  def handle_cast({:put, key, data}, state) do
    :ets.insert(:conversions_cache, {key, data})

    Process.send_after(self(), {:expire, key}, @ttl)

    {:noreply, state}
  end

  def handle_cast(:clear, state) do
    :ets.delete(:conversions_cache)
    create_table()
    {:noreply, state}
  end

  def handle_info({:expire, key}, state) do
    :ets.delete(:conversions_cache, key)
    {:noreply, state}
  end

  defp create_table do
    :ets.new(:conversions_cache, [:named_table, write_concurrency: true, read_concurrency: true])
  end
end
