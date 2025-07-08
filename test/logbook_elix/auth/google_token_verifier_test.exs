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

    test "extracts user info from valid claims" do
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

    test "validates issuer correctly" do
      valid_issuers = GoogleTokenVerifier.valid_issuers()
      
      assert "https://accounts.google.com" in valid_issuers
      assert "accounts.google.com" in valid_issuers
      refute "https://evil.com" in valid_issuers
    end

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