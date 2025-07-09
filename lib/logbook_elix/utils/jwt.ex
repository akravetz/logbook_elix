defmodule LogbookElix.Utils.JWT do
  @moduledoc """
  Utilities for JWT token parsing and manipulation.
  """

  @doc """
  Parses a specific segment from a JWT token.

  ## Parameters
  - `token`: The JWT token string
  - `segment_index`: The segment to parse (0 for header, 1 for payload)

  ## Returns
  - `{:ok, parsed_segment}` on success
  - `{:error, reason}` on failure
  """
  def parse_segment(token, segment_index) do
    case String.split(token, ".") do
      segments when length(segments) >= segment_index + 1 ->
        segment = Enum.at(segments, segment_index)

        with {:ok, decoded} <- Base.url_decode64(segment, padding: false),
             {:ok, parsed} <- Jason.decode(decoded) do
          {:ok, parsed}
        else
          _ -> {:error, "Invalid JWT format"}
        end

      _ ->
        {:error, "Invalid JWT format"}
    end
  end

  @doc """
  Parses the header segment (index 0) of a JWT token.
  """
  def parse_header(token), do: parse_segment(token, 0)

  @doc """
  Parses the payload/claims segment (index 1) of a JWT token.
  """
  def parse_claims(token), do: parse_segment(token, 1)
end
