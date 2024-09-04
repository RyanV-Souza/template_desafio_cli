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
  def new() do
    %KeyValueStorage{}
  end

  @doc """
  Gets the value of a key in the storage.
  """
  @spec get(t(), key()) :: value() | String.t()
  def get(%KeyValueStorage{db: db}, key) do
    Map.get(db, key, "NIL")
  end
end
