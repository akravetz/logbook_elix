defmodule LogbookElix.Auth.GoogleTokenVerifierIntegrationTest do
  use LogbookElix.DataCase

  alias LogbookElix.Auth.GoogleTokenVerifier
  import JwtTestHelper

  # This is an actual Google ID token for testing
  # Note: This token is expired and should only be used for testing token parsing
  @real_google_token "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFjMmI2ZmFmMDNlOGU0MWM0MzA0YjhkZmE4MjExODQ2OGJiODk4OGEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMDE1NTM1OTQ2NTg2OTgyOTUwMi5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjEwMTU1MzU5NDY1ODY5ODI5NTAyLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTE0MDQ3OTEyODI0MTQ3MjIzNDE4IiwiZW1haWwiOiJjcHBjb2RlckBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IkNQUCBDb2RlciIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQVRYQUp5RzRUQzJQcDRULXhQRVRzLUxJa1ZfVXJnUDR3VTU5YmhlWHpJPXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6IkNQUCIsImZhbWlseV9uYW1lIjoiQ29kZXIiLCJsb2NhbGUiOiJlbiIsImlhdCI6MTY0MjYxNjQwMCwiZXhwIjoxNjQyNjIwMDAwfQ.XnZTx8NYXwR4kxHgRADOj4zM_i3fHqBYrnZFCD-FqrABQWYTZzOR9xGhwvLz9R1_aPcDfH-vH_2GmPvGzPYPwZYKMHvKOIxCLJ7xdHrKoKMxAKhVJpO9eGvvx_JxKsHQJOtbO9hhXTM1vKXmK5OWhkLvyFHBdxQEQenAFRmOtMGXYIIJrMfhSJGPnkJ_kHf_R4vbHcF1M-BKxlhMPqKn6F0H8kH_NsGvgQ4JKlHsZxDzt1K7vhXQfmxKqgxR0rQMXMZ1_gJKmZrqZpqaQKxn3CQdHpbQkRHxlPGNlOVYxNG4KkFECPM2lYXpjmKQXH_YSYBxQGQYLQ6_H5MaUg"
  @expected_kid_1 "ac2b6faf03e8e41c4304b8dfa82118468bb8988a"
  @expected_kid_2 "8e8fc8e556f7a76d08d35829d6f90ae2e12cfd0d"

  describe "verify_token/1 with real token structure" do

    test "can parse JWT header from real Google token" do
      {:ok, header} = parse_jwt_header(@real_google_token)

      assert header["alg"] == "RS256"
      assert header["kid"] == @expected_kid_1
      assert header["typ"] == "JWT"
    end

    test "can parse JWT claims from real Google token" do
      {:ok, claims} = parse_jwt_claims(@real_google_token)

      assert claims["iss"] == "https://accounts.google.com"
      assert claims["email"] == "cppcoder@gmail.com"
      assert claims["name"] == "CPP Coder"
      assert claims["sub"] == "114047912824147223418"
      assert claims["email_verified"] == true
    end

    test "extracts correct user info from real token claims" do
      {:ok, claims} = parse_jwt_claims(@real_google_token)
      user_info = extract_user_info_from_claims(claims)

      assert user_info.google_id == "114047912824147223418"
      assert user_info.email == "cppcoder@gmail.com"
      assert user_info.name == "CPP Coder"
      assert user_info.profile_image_url =~ "https://lh3.googleusercontent.com/"
    end

    test "validates issuer correctly" do
      valid_issuers = GoogleTokenVerifier.valid_issuers()
      
      assert "https://accounts.google.com" in valid_issuers
      assert "accounts.google.com" in valid_issuers
      refute "https://evil.com" in valid_issuers
    end

    test "handles access token format (ya29...) differently from ID token" do
      access_token = "ya29.a0AS3H6NxS1mMM6hNstnwcS6FVDbq819xYUcifhnV-WdmRGBXO_RMIs9V1Ecu1i0Y9cJu2-OkBm66cTDFEj6JX73GCBwXLwV7ihe7VzlmqBpQxluDttTKmJTqk0laaYBdSSkB5gNwgvtcyzpBa5Ea7naR7ryCw-2WaTdF06hrzaCgYKAUgSARASFQHGX2MiygJbSJRBGXd4xT4exUdoKg0175"
      
      # Access tokens don't have the JWT structure (header.payload.signature)
      segments = String.split(access_token, ".")
      assert length(segments) != 3
      
      # Therefore, verify_token should fail for access tokens
      assert {:error, _} = GoogleTokenVerifier.verify_token(access_token)
    end
    
    test "can parse real Google ID token structure" do
      id_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjhlOGZjOGU1NTZmN2E3NmQwOGQzNTgyOWQ2ZjkwYWUyZTEyY2ZkMGQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI4MTg2OTE2MTk0MDItZXFvYjIybjNvdW05bmI5cDE0c2liNzNhaXFudmdvNGUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI4MTg2OTE2MTk0MDItZXFvYjIybjNvdW05bmI5cDE0c2liNzNhaXFudmdvNGUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTQ0NjA1MjEyNDAzODgzNzE5OTgiLCJlbWFpbCI6ImNwcGNvZGVyQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiSzc4ZUMtcHc5UVZicVp6Q1o2M01fUSIsImlhdCI6MTc1MTk0MTUyMSwiZXhwIjoxNzUxOTQ1MTIxfQ.AR2eSHBK1zfABFFipU1T9iqy3EdK0fqhG3TS4OlZ4fUQL12jsXQiPeMtRRZUCVF2vPrqkfMn8gMgOZjqPaUza9aP3m6SvaYpqMb9WMhaDhvyR11Po35TENu4RvRkUNh2AXX_Pcav58h7Uo01ncB92KA1zECAWpnRnn6Y2U9EnJ8cQWUcmlpo3ZeaYzPIEnNZj03O2mwaThNphHHL2W0Lz-SabmSd_o6HGGEYTAEmyXfkIUIlIAI_jtyqQRv_UtOCKTcC0WH1uEJkCoZs6tSnHWH2abmI7UAW770UMGpZPm8l-x9hpeB_1_X1tw3d0_u-LHdeFI5SMjLkaFCT2BaMEg"
      
      {:ok, header} = parse_jwt_header(id_token)
      assert header["alg"] == "RS256"
      assert header["kid"] == @expected_kid_2
      assert header["typ"] == "JWT"
      
      {:ok, claims} = parse_jwt_claims(id_token)
      assert claims["iss"] == "https://accounts.google.com"
      assert claims["email"] == "cppcoder@gmail.com"
      assert claims["sub"] == "114460521240388371998"
      assert claims["email_verified"] == true
    end
  end
end