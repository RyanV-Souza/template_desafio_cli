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
end
