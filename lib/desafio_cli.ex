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

      {:error, msg} ->
        IO.puts("ERR \"#{msg}\"")
        loop(storage)

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

        case parse_key(key) do
          {:error, msg} ->
            IO.puts("Erro na chave: #{key}")
            {:error, msg}

          {:ok, parsed_key} ->
            case parse_value(value, has_escape_string) do
              {:error, msg} ->
                IO.puts("Erro no valor: #{value}")
                {:error, msg}

              {:ok, parsed_value} ->
                {:set, parsed_key, parsed_value}
            end
        end

      ["SET", _] ->
        {:error, "SET <chave> <valor> - Syntax error"}

      ["GET", key] ->
        case parse_key(key) do
          {:error, msg} ->
            IO.puts("Erro na chave: #{key}")
            {:error, msg}

          {:ok, parsed_key} ->
            {:get, parsed_key}
        end

      ["GET"] ->
        {:error, "GET <chave> - Syntax error"}

      _ ->
        :error
    end
  end

  defp parse_key(key) do
    cond do
      !String.starts_with?(key, "'") and !String.ends_with?(key, "'") ->
        {:error, "Key starts with ' and ends with '"}

      String.contains?(key, " ") ->
        {:error, "Key contains space"}

      true ->
        {:ok, String.trim(key, "'")}
    end
  end

  defp parse_value(value, has_escape_string) do
    cond do
      String.upcase(value) in ["TRUE", "FALSE", "NIL"] ->
        {:error, "The value is a boolean"}

      has_escape_string ->
        {:ok, "#{value}"}

      String.starts_with?(value, "\"") and String.ends_with?(value, "\"") ->
        {:ok, String.trim(value, "\"")}

      true ->
        {:ok, String.trim(value, "\"")}
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
