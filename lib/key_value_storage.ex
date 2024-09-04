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
  def set(%KeyValueStorage{transactions: [t | rest]} = storage, key, value) do
    existed = Map.has_key?(t, key)
    new_t = Map.put(t, key, value)
    {existed, %KeyValueStorage{storage | transactions: [new_t | rest]}}
  end

  def set(%KeyValueStorage{db: db, transactions: []} = storage, key, value) do
    existed = Map.has_key?(db, key)
    new_db = Map.put(db, key, value)
    {existed, %KeyValueStorage{storage | db: new_db}}
  end

  @doc """
  Gets the value of a key in the storage.
  """
  @spec get(t(), key()) :: value() | String.t()
  def get(%KeyValueStorage{transactions: [t | _]}, key) do
    case Map.get(t, key) do
      nil -> get(%KeyValueStorage{transactions: []}, key)
      value -> value
    end
  end

  def get(%KeyValueStorage{db: db}, key) do
    Map.get(db, key, "NIL")
  end

  @doc """
  Begins a new transaction.
  """
  @spec begin(t()) :: t()
  def begin(%KeyValueStorage{transactions: transactions} = storage) do
    %KeyValueStorage{storage | transactions: [%{} | transactions]}
  end

  @doc """
  Rollback the last transaction.
  """
  @spec rollback(t()) :: t() | {:error, String.t()}
  def rollback(%KeyValueStorage{transactions: []}) do
    {:error, "No transaction"}
  end

  def rollback(%KeyValueStorage{transactions: [_ | rest]} = storage) do
    %KeyValueStorage{storage | transactions: rest}
  end

  @doc """
  Commits the last transaction.
  """
  @spec commit(t()) :: t() | {:error, String.t()}
  def commit(%KeyValueStorage{transactions: []}) do
    {:error, "No transaction"}
  end

  def commit(%KeyValueStorage{transactions: [t1, t2 | rest]} = storage) do
    new_transaction = Map.merge(t2, t1)

    %KeyValueStorage{storage | transactions: [new_transaction | rest]}
  end

  def commit(%KeyValueStorage{transactions: [t]} = storage) do
    new_db = Map.merge(storage.db, t)
    %KeyValueStorage{storage | db: new_db, transactions: []}
  end
end
