defmodule KeyValueStorage do
  @moduledoc """
  Represents a key-value storage.
  """

  defstruct db: %{}, transactions: []

  @type key :: String.t()
  @type value :: integer() | String.t() | boolean()
  @type db :: %{optional(key) => value}
  @type transaction :: %{optional(key) => value}
  @type t :: %KeyValueStorage{
          db: db(),
          transactions: [transaction()]
        }

  @doc """
  Creates a new key-value storage.
  """
  @spec new() :: KeyValueStorage.t()
  def new() do
    %KeyValueStorage{}
  end

  @doc """
  Sets the value of a key in the storage.
  """
  @spec set(t(), key(), value()) :: {boolean(), t()}
  def set(%KeyValueStorage{db: db, transactions: []} = storage, key, value) do
    existed = Map.has_key?(db, key)
    new_db = Map.put(db, key, value)
    {existed, %KeyValueStorage{storage | db: new_db}}
  end

  @doc """
  Gets the value of a key in the storage.
  """
  @spec get(t(), key()) :: value() | String.t()
  def get(%KeyValueStorage{db: db}, key) do
    Map.get(db, key, "NIL")
  end
end
