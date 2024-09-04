defmodule DesafioCli do
  alias KeyValueStorage

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

      {:set, key, value} ->
        {existed, storage} = KeyValueStorage.set(storage, key, value)
        IO.puts("#{String.upcase(to_string(existed))} #{value}")
        loop(storage)

      _ ->
        :error
        IO.puts("ERR \"No command #{input}\"")
        loop(storage)
    end
  end

  defp parse_input(input) do
    case String.split(input) do
      ["SET", key, value] -> {:set, key, parse_value(value)}
      ["GET", key] -> {:get, key}
      _ -> :error
    end
  end

  defp parse_value(value) do
    case Integer.parse(value) do
      {int_value, ""} -> int_value
      _ -> value
    end
  end
end
