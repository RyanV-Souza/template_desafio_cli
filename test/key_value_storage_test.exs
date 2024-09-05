defmodule KeyValueStorageTest do
  use ExUnit.Case
  alias KeyValueStorage
  doctest KeyValueStorage

  describe "new/0" do
    test "creates a new empty storage" do
      storage = KeyValueStorage.new()
      assert storage.db == %{}
      assert storage.transactions == []
    end
  end

  describe "set/3" do
    test "sets a value in the storage db without transactions" do
      storage = KeyValueStorage.new()
      {existed, new_storage} = KeyValueStorage.set(storage, "my_key", "my_value")

      assert existed == false
      assert new_storage.db == %{"my_key" => "my_value"}
    end

    test "updates an existing key in the storage db" do
      storage = KeyValueStorage.new() |> KeyValueStorage.set("my_key", "old_value") |> elem(1)
      {existed, new_storage} = KeyValueStorage.set(storage, "my_key", "new_value")

      assert existed == true
      assert new_storage.db == %{"my_key" => "new_value"}
    end

    test "sets a value inside an active transaction" do
      storage = KeyValueStorage.new() |> KeyValueStorage.begin()
      {existed, new_storage} = KeyValueStorage.set(storage, "my_key", "my_value")

      assert existed == false
      assert hd(new_storage.transactions) == %{"my_key" => "my_value"}
    end
  end

  describe "get/2" do
    test "gets a value from the storage db" do
      storage = KeyValueStorage.new() |> KeyValueStorage.set("my_key", "my_value") |> elem(1)
      value = KeyValueStorage.get(storage, "my_key")

      assert value == "my_value"
    end

    test "returns 'NIL' for a non-existing key in the db" do
      storage = KeyValueStorage.new()
      value = KeyValueStorage.get(storage, "unknown_key")

      assert value == "NIL"
    end

    test "gets a value from the active transaction" do
      storage =
        KeyValueStorage.new()
        |> KeyValueStorage.begin()
        |> KeyValueStorage.set("my_key", "my_value")
        |> elem(1)

      value = KeyValueStorage.get(storage, "my_key")

      assert value == "my_value"
    end
  end

  describe "begin/1" do
    test "starts a new transaction" do
      storage = KeyValueStorage.new() |> KeyValueStorage.begin()

      assert length(storage.transactions) == 1
    end
  end
end
