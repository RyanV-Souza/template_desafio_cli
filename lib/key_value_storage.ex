defmodule KeyValueStorage do
 defstruct db: %{}, transactions: []

 def new() do
   %KeyValueStorage{}
 end

 def get(%KeyValueStorage{db: db}, key) do
  Map.get(db, key, "NIL")
 end

end
