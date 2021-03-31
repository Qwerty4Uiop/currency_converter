defmodule CurrencyConverter.Model do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      @type t :: %__MODULE__{}

      @primary_key {:id, :binary_id, autogenerate: true}
    end
  end
end
