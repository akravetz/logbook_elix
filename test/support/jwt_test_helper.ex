defmodule JwtTestHelper do
  @moduledoc """
  Helper functions for JWT testing across different test modules.
  """

  alias LogbookElix.Utils.JWT

  @doc """
  Parses JWT header from a token string.
  """
  def parse_jwt_header(token) do
    JWT.parse_header(token)
  end

  @doc """
  Parses JWT claims from a token string.
  """
  def parse_jwt_claims(token) do
    JWT.parse_claims(token)
  end

  @doc """
  Extracts user info from JWT claims using the same logic as the verifier.
  """
  def extract_user_info_from_claims(claims) do
    LogbookElix.Auth.GoogleTokenVerifier.extract_user_info(claims)
  end
end
