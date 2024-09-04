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
    regex = ~r/'[^']*'|\"[^\"]*\"|\S+/

    {new_input, has_escape_string} = remove_escape_string(input)

    case Regex.scan(regex, to_string(new_input)) |> List.flatten() |> Enum.reject(&(&1 == "")) do
      ["SET", key, value] ->
        IO.puts(key)
        IO.puts(value)

        key = parse_key(key)

        case parse_value(value, has_escape_string) do
          :error -> :error
          parsed_value -> {:set, key, parsed_value}
        end

      ["GET", key] ->
        key = parse_key(key)
        {:get, key}

      _ ->
        :error
    end
  end

  defp parse_key(key) do
    cond do
      String.starts_with?(key, "\"") and String.ends_with?(key, "\"") ->
        :error

      String.contains?(key, " ") ->
        :error

      String.starts_with?(key, "'") and String.ends_with?(key, "'") ->
        String.trim(key, "'")
    end
  end

  defp parse_value(value, has_escape_string) do
    cond do
      String.upcase(value) in ["TRUE", "FALSE", "NIL"] ->
        :error

      has_escape_string ->
        "#{value}"

      String.starts_with?(value, "\"") and String.ends_with?(value, "\"") ->
        String.trim(value, "\"")

      true ->
        String.trim(value, "\"")
    end
  end

  defp remove_escape_string(string) do
    if String.contains?(string, "\\") do
      new_string =
        string
        |> String.trim()
        |> String.replace(~r/\\"/, "")

      IO.puts("NEW STRING #{new_string}")
      {new_string, true}
    end

    {string, false}
  end
end
