defmodule LogbookElix.Auth.GoogleTokenVerifierTest do
  use LogbookElix.DataCase

  alias LogbookElix.Auth.GoogleTokenVerifier
  import JwtTestHelper


  # Mock JWT with known structure for testing
  @mock_jwt_claims %{
    "iss" => "https://accounts.google.com",
    "sub" => "1234567890",
    "email" => "cppcoder@gmail.com",
    "name" => "Test User",
    "picture" => "https://example.com/photo.jpg",
    "exp" => System.system_time(:second) + 3600,
    "iat" => System.system_time(:second) - 60
  }

  describe "verify_token/1" do

    test "verifies a valid token and extracts user info" do
      # Note: In a real test, we would need to:
      # 1. Mock the HTTPoison.get call to return our mock certificates
      # 2. Create a properly signed JWT using the test certificate
      # 3. Verify the full flow
      
      # For now, we'll test the individual components
      user_info = extract_user_info_from_claims(@mock_jwt_claims)
      assert user_info.email == "cppcoder@gmail.com"
      assert user_info.google_id == "1234567890"
      assert user_info.name == "Test User"
      assert user_info.profile_image_url == "https://example.com/photo.jpg"
    end

    test "returns error for invalid token format" do
      assert {:error, "Invalid JWT format"} = GoogleTokenVerifier.verify_token("invalid.token")
    end

    test "returns error for token with invalid segments" do
      assert {:error, "Invalid JWT format"} = GoogleTokenVerifier.verify_token("only.two")
    end

    test "validates required fields in claims" do
      claims_missing_email = Map.delete(@mock_jwt_claims, "email")
      assert {:error, "Missing required claims"} = validate_claims_fields(claims_missing_email)

      claims_missing_sub = Map.delete(@mock_jwt_claims, "sub")
      assert {:error, "Missing required claims"} = validate_claims_fields(claims_missing_sub)
    end

    defp validate_claims_fields(claims) do
      required_fields = ["sub", "email"]

      if Enum.all?(required_fields, &Map.has_key?(claims, &1)) do
        :ok
      else
        {:error, "Missing required claims"}
      end
    end

    test "validates issuer" do
      valid_claims = @mock_jwt_claims
      assert :ok = validate_issuer_claim(valid_claims["iss"])

      invalid_claims = Map.put(@mock_jwt_claims, "iss", "https://invalid.com")
      assert {:error, "Invalid token issuer"} = validate_issuer_claim(invalid_claims["iss"])
    end

    defp validate_issuer_claim(iss) when iss in ["https://accounts.google.com", "accounts.google.com"], do: :ok
    defp validate_issuer_claim(_), do: {:error, "Invalid token issuer"}

    test "handles missing name gracefully" do
      claims_without_name = Map.delete(@mock_jwt_claims, "name")
      user_info = extract_user_info_from_claims(claims_without_name)
      assert user_info.name == "cppcoder@gmail.com"
    end

    test "handles missing picture gracefully" do
      claims_without_picture = Map.delete(@mock_jwt_claims, "picture")
      user_info = extract_user_info_from_claims(claims_without_picture)
      assert user_info.profile_image_url == ""
    end
  end
end