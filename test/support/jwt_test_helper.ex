defmodule JwtTestHelper do
  @moduledoc """
  Helper functions for JWT testing across different test modules.
  """


  @doc """
  Parses JWT header from a token string.
  """
  def parse_jwt_header(token) do
    parse_jwt_segment(token, 0)
  end

  @doc """
  Parses JWT claims from a token string.
  """
  def parse_jwt_claims(token) do
    parse_jwt_segment(token, 1)
  end

  defp parse_jwt_segment(token, segment_index) do
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
  Extracts user info from JWT claims using the same logic as the verifier.
  """
  def extract_user_info_from_claims(claims) do
    LogbookElix.Auth.GoogleTokenVerifier.extract_user_info(claims)
  end
end