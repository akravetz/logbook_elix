defmodule LogbookElix.Auth.GoogleTokenVerifier do
  @moduledoc """
  Verifies Google OAuth2 ID tokens using Google's public certificates.
  """

  require Logger

  alias LogbookElix.Utils.JWT

  @google_certs_url "https://www.googleapis.com/oauth2/v1/certs"
  @valid_issuers ["https://accounts.google.com", "accounts.google.com"]
  @cache_name :google_certs_cache
  @cache_key "google_certs"

  @doc """
  Returns the list of valid token issuers for Google OAuth tokens.
  """
  def valid_issuers, do: @valid_issuers

  def verify_token(id_token) do
    with {:ok, header} <- JWT.parse_header(id_token),
         {:ok, certs} <- get_cached_or_fetch_certs(),
         {:ok, jwk} <- find_cert_by_kid(certs, header["kid"]),
         {:ok, claims} <- verify_and_decode_jwt(id_token, jwk),
         :ok <- validate_claims(claims) do
      {:ok, extract_user_info(claims)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_cached_or_fetch_certs do
    case Cachex.get(@cache_name, @cache_key) do
      {:ok, nil} ->
        fetch_and_cache_certs()

      {:ok, certs} ->
        {:ok, certs}

      {:error, _} ->
        fetch_and_cache_certs()
    end
  end

  defp fetch_and_cache_certs do
    case HTTPoison.get(@google_certs_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, certs} ->
            # Cache for 1 hour
            Cachex.put(@cache_name, @cache_key, certs, ttl: :timer.hours(1))
            {:ok, certs}

          {:error, _} ->
            {:error, "Failed to parse Google certificates"}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch Google certificates: #{inspect(reason)}"}
    end
  end

  defp find_cert_by_kid(certs, kid) when is_binary(kid) do
    case Map.get(certs, kid) do
      nil ->
        {:error, "Certificate not found for kid: #{kid}"}

      cert_pem ->
        # Convert PEM certificate to JWK
        case JOSE.JWK.from_pem(cert_pem) do
          jwk when is_map(jwk) ->
            {:ok, jwk}

          _ ->
            {:error, "Failed to parse certificate"}
        end
    end
  end

  defp find_cert_by_kid(_certs, _kid) do
    {:error, "Invalid key ID"}
  end

  defp verify_and_decode_jwt(token, jwk) do
    case JOSE.JWT.verify_strict(jwk, ["RS256"], token) do
      {true, jwt, _jws} ->
        {:ok, jwt.fields}

      {false, _, _} ->
        {:error, "Invalid JWT signature"}

      _ ->
        {:error, "JWT verification failed"}
    end
  end

  defp validate_claims(claims) do
    with :ok <- validate_issuer(claims["iss"]),
         :ok <- validate_expiration(claims["exp"]),
         :ok <- validate_issued_at(claims["iat"]),
         :ok <- validate_required_fields(claims) do
      :ok
    end
  end

  defp validate_issuer(iss) when iss in @valid_issuers, do: :ok
  defp validate_issuer(_), do: {:error, "Invalid token issuer"}

  defp validate_expiration(exp) when is_integer(exp) do
    current_time = System.system_time(:second)

    if exp > current_time do
      :ok
    else
      {:error, "Token has expired"}
    end
  end

  defp validate_expiration(_), do: {:error, "Invalid expiration claim"}

  defp validate_issued_at(iat) when is_integer(iat) do
    current_time = System.system_time(:second)
    # Allow 5 minutes of clock skew
    max_skew = 300

    if iat <= current_time + max_skew do
      :ok
    else
      {:error, "Token issued in the future"}
    end
  end

  defp validate_issued_at(_), do: {:error, "Invalid issued_at claim"}

  defp validate_required_fields(claims) do
    required_fields = ["sub", "email"]

    if Enum.all?(required_fields, &Map.has_key?(claims, &1)) do
      :ok
    else
      {:error, "Missing required claims"}
    end
  end

  @doc """
  Extracts user info from JWT claims.
  """
  def extract_user_info(claims) do
    %{
      google_id: claims["sub"],
      email: claims["email"],
      name: claims["name"] || claims["email"],
      profile_image_url: claims["picture"] || ""
    }
  end
end
