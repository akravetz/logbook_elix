defmodule LogbookElix.Auth.GoogleTokenVerificationFlowTest do
  use LogbookElix.DataCase

  alias LogbookElix.Auth.GoogleTokenVerifier
  import JwtTestHelper

  @real_google_id_token "eyJhbGciOiJSUzI1NiIsImtpZCI6IjhlOGZjOGU1NTZmN2E3NmQwOGQzNTgyOWQ2ZjkwYWUyZTEyY2ZkMGQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI4MTg2OTE2MTk0MDItZXFvYjIybjNvdW05bmI5cDE0c2liNzNhaXFudmdvNGUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI4MTg2OTE2MTk0MDItZXFvYjIybjNvdW05bmI5cDE0c2liNzNhaXFudmdvNGUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTQ0NjA1MjEyNDAzODgzNzE5OTgiLCJlbWFpbCI6ImNwcGNvZGVyQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiSzc4ZUMtcHc5UVZicVp6Q1o2M01fUSIsImlhdCI6MTc1MTk0MTUyMSwiZXhwIjoxNzUxOTQ1MTIxfQ.AR2eSHBK1zfABFFipU1T9iqy3EdK0fqhG3TS4OlZ4fUQL12jsXQiPeMtRRZUCVF2vPrqkfMn8gMgOZjqPaUza9aP3m6SvaYpqMb9WMhaDhvyR11Po35TENu4RvRkUNh2AXX_Pcav58h7Uo01ncB92KA1zECAWpnRnn6Y2U9EnJ8cQWUcmlpo3ZeaYzPIEnNZj03O2mwaThNphHHL2W0Lz-SabmSd_o6HGGEYTAEmyXfkIUIlIAI_jtyqQRv_UtOCKTcC0WH1uEJkCoZs6tSnHWH2abmI7UAW770UMGpZPm8l-x9hpeB_1_X1tw3d0_u-LHdeFI5SMjLkaFCT2BaMEg"
  @expected_kid "8e8fc8e556f7a76d08d35829d6f90ae2e12cfd0d"

  describe "Google ID token verification" do
    test "extracts correct header information from real Google ID token" do
      {:ok, header} = parse_jwt_header(@real_google_id_token)

      assert header["alg"] == "RS256"
      assert header["kid"] == @expected_kid
      assert header["typ"] == "JWT"
    end

    test "extracts correct claims from real Google ID token" do
      {:ok, claims} = parse_jwt_claims(@real_google_id_token)

      assert claims["iss"] == "https://accounts.google.com"
      assert claims["azp"] == "818691619402-eqob22n3oum9nb9p14sib73aiqnvgo4e.apps.googleusercontent.com"
      assert claims["aud"] == "818691619402-eqob22n3oum9nb9p14sib73aiqnvgo4e.apps.googleusercontent.com"
      assert claims["sub"] == "114460521240388371998"
      assert claims["email"] == "cppcoder@gmail.com"
      assert claims["email_verified"] == true
      assert claims["at_hash"] == "K78eC-pw9QVbqZzCZ63M_Q"
      assert claims["iat"] == 1751941521
      assert claims["exp"] == 1751945121
    end

    test "token verification would extract correct user info" do
      {:ok, claims} = parse_jwt_claims(@real_google_id_token)
      user_info = extract_user_info_from_claims(claims)

      assert user_info.google_id == "114460521240388371998"
      assert user_info.email == "cppcoder@gmail.com"
      assert user_info.name == "cppcoder@gmail.com"  # No name field in this token
      assert user_info.profile_image_url == ""  # No picture field in this token
    end

    test "peek_jwt_header works correctly with real token" do
      {:ok, header} = parse_jwt_header(@real_google_id_token)
      assert header["kid"] == @expected_kid
    end

    test "validates issuer correctly from real token" do
      {:ok, claims} = parse_jwt_claims(@real_google_id_token)
      assert claims["iss"] in GoogleTokenVerifier.valid_issuers()
    end

    test "real token has all required fields" do
      {:ok, claims} = parse_jwt_claims(@real_google_id_token)

      # Check required fields
      assert Map.has_key?(claims, "sub")
      assert Map.has_key?(claims, "email")
      assert Map.has_key?(claims, "iss")
      assert Map.has_key?(claims, "exp")
      assert Map.has_key?(claims, "iat")
    end
  end
end