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
        IO.puts("SET Method")
        {existed, storage} = KeyValueStorage.set(storage, key, value)
        IO.puts("#{String.upcase(to_string(existed))} #{value}")
        loop(storage)

      :begin ->
        storage = KeyValueStorage.begin(storage)
        IO.puts(length(storage.transactions))
        loop(storage)

      :rollback ->
        updated_storage =
          case KeyValueStorage.rollback(storage) do
            {:error, msg} ->
              IO.puts("ERR \"#{msg}\"")
              storage

            storage ->
              IO.puts(length(storage.transactions))
              storage
          end

        loop(updated_storage)

      :commit ->
        updated_storage =
          case KeyValueStorage.commit(storage) do
            {:error, msg} ->
              IO.puts("ERR \"#{msg}\"")
              storage

            storage ->
              IO.puts(length(storage.transactions))
              storage
          end

        loop(updated_storage)

      _ ->
        :error
        IO.puts("ERR \"No command #{input}\"")
        loop(storage)
    end
  end

  defp parse_input("BEGIN"), do: :begin
  defp parse_input("ROLLBACK"), do: :rollback
  defp parse_input("COMMIT"), do: :commit

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
