defmodule LogbookElix.Services.DeepgramClientTest do
  use LogbookElix.DataCase

  alias LogbookElix.Services.DeepgramClient

  describe "transcribe_audio/2" do
    test "successfully parses DeepGram response" do
      # Mock HTTPoison response
      mock_response = %{
        "results" => %{
          "channels" => [
            %{
              "alternatives" => [
                %{
                  "transcript" => "Hello world",
                  "confidence" => 0.95,
                  "words" => [
                    %{"word" => "Hello", "start" => 0.0, "end" => 0.5, "confidence" => 0.97},
                    %{"word" => "world", "start" => 0.6, "end" => 1.0, "confidence" => 0.93}
                  ]
                }
              ]
            }
          ]
        }
      }

      # We would normally use Mox or similar for mocking HTTP calls
      # For now, we'll test the parsing function directly
      assert {:ok, alternative} =
               DeepgramClient.parse_transcription_response(Jason.encode!(mock_response))

      assert alternative["transcript"] == "Hello world"
      assert alternative["confidence"] == 0.95
      assert length(alternative["words"]) == 2
    end

    test "handles invalid response format" do
      invalid_response = %{"results" => %{}}

      assert {:error, "Unexpected response format from DeepGram"} =
               DeepgramClient.parse_transcription_response(Jason.encode!(invalid_response))
    end

    test "handles JSON parsing errors" do
      assert {:error, "Failed to parse DeepGram response"} =
               DeepgramClient.parse_transcription_response("invalid json")
    end
  end
end
