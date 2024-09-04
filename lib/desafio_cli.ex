defmodule DesafioCli do

  def main(_args) do
    IO.puts("[Desafio] Banco de dados chave-valor")
    storage = KeyValueStorage.new()
    loop(storage)
  end

  def loop(storage) do
    IO.write("> ")
    input = IO.gets("") |> String.trim()

    case parse_input(input) do
      {:get, key} ->
        value = KeyValueStorage.get(storage, key)
        IO.puts(value)
        loop(storage)

      _ -> :error
        IO.puts("ERR \"No command #{input}\"")
        loop(storage)
    end

  end

  defp parse_input(input) do
    case String.split(input) do
      ["GET", key] -> {:get, key}
      _ -> :error
    end
  end
end
