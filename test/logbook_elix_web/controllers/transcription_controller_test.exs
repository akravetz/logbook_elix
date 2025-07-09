defmodule LogbookElixWeb.TranscriptionControllerTest do
  use LogbookElixWeb.ConnCase

  import LogbookElixWeb.AuthTestHelper

  setup %{conn: conn} do
    conn =
      conn
      |> authenticated_conn()

    {:ok, conn: conn}
  end

  describe "create transcription" do
    test "returns error when content-type header is missing", %{conn: conn} do
      conn =
        conn
        |> delete_req_header("content-type")
        |> post(~p"/api/transcriptions")

      assert json_response(conn, 401)["error"] == "Content-Type header is required"
    end

    test "returns error for invalid content type", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "text/plain")
        |> post(~p"/api/transcriptions", "not audio")

      assert json_response(conn, 401)["error"] ==
               "Invalid content type. Supported formats: wav, mp3, m4a, webm"
    end

    @tag :skip
    test "returns error when audio file is too large", %{_conn: _conn} do
      # This would require mocking Plug.Conn.read_body to return {:more, _, _}
      # Skipping for now
    end

    test "handles rate limiting", %{conn: conn} do
      # Make 10 requests (the limit)
      for _ <- 1..10 do
        new_conn =
          conn
          |> put_req_header("content-type", "audio/wav")
          |> post(~p"/api/transcriptions", "audio data")

        # These will fail due to test API key, but that's ok
        assert response(new_conn, 401)
      end

      # The 11th request should be rate limited
      conn =
        conn
        |> put_req_header("content-type", "audio/wav")
        |> post(~p"/api/transcriptions", "audio data")

      assert response(conn, 429)
      response_body = json_response(conn, 429)
      assert response_body["error"] == "Rate limit exceeded"
    end
  end
end
