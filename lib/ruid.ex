defmodule Ruid do
 @moduledoc """
  Generate a 64-bit UUID having the format:
  <<_::8(type), _::48(ts), _::8(unused)>>.
  By including the creation time in the id, there's no need for a created_at column in the DB table.
  """

  @doc """
  Generate a 64-bit id.
  Type code is a 1-byte integer common to a resource type.
  E.g 10 for users, 20 for roles etc
  """
  @spec generate(integer()) :: integer()
  def generate(resource_code) when is_integer(resource_code) do
    <<unused::8>> = :crypto.strong_rand_bytes(1) # Get a random byte

    ts_bits =
      DateTime.utc_now
      |> DateTime.to_unix(:milliseconds)
      |> Integer.to_string(2)
      |> pad_bits(48)

    type_bits =
      resource_code
      |> Integer.to_string(2)
      |> pad_bits

    unused_bits =
      unused
      |> Integer.to_string(2)
      |> pad_bits

    "#{type_bits}#{ts_bits}#{unused_bits}"
    |> Integer.parse(2)
    |> elem(0)
  end

  defp pad_bits(bit_str, bit_length \\ 8) when is_binary(bit_str) do
    case String.length(bit_str) do
      x when x >= bit_length ->
        String.slice(bit_str, 0, bit_length) # The whole string will be returned if bit_str is shorter than bit_length
      x when x < bit_length ->
        String.pad_leading(bit_str, bit_length, "0")
    end
  end

  @doc """
  Convert 64-bit to hex string.
  """
  @spec to_string(integer()) :: binary()
  def to_string(id) when is_integer(id) do
    id
    |> Integer.to_string(16)
    |> String.downcase
  end

  @doc """
  Convert hex string to 64-bit id.
  """
  @spec from_string(binary()) :: integer()
  def from_string(id_str) when is_binary(id_str) do
    id_str
    |> Integer.parse(16)
    |> elem(0)
  end
end
