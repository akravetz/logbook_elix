defmodule JwtTestHelper do
  @moduledoc """
  Helper functions for JWT testing across different test modules.
  """

  @doc """
  Parses JWT header from a token string.
  """
  def parse_jwt_header(token) do
    case String.split(token, ".") do
      [header_segment | _] ->
        with {:ok, decoded} <- Base.url_decode64(header_segment, padding: false),
             {:ok, header} <- Jason.decode(decoded) do
          {:ok, header}
        else
          _ -> {:error, "Invalid JWT format"}
        end

      _ ->
        {:error, "Invalid JWT format"}
    end
  end

  @doc """
  Parses JWT claims from a token string.
  """
  def parse_jwt_claims(token) do
    case String.split(token, ".") do
      [_, claims_segment | _] ->
        with {:ok, decoded} <- Base.url_decode64(claims_segment, padding: false),
             {:ok, claims} <- Jason.decode(decoded) do
          {:ok, claims}
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
    %{
      google_id: claims["sub"],
      email: claims["email"],
      name: claims["name"] || claims["email"],
      profile_image_url: claims["picture"] || ""
    }
  end
end