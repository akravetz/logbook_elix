defmodule LogbookElix.Services.DeepgramClientTest do
  use LogbookElix.DataCase

  alias LogbookElix.Services.DeepgramClient

  describe "transcribe_audio/2" do
    test "successfully parses DeepGram response from JSON string" do
      # Mock Req response as JSON string
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

      # Test parsing from JSON string
      assert {:ok, alternative} =
               DeepgramClient.parse_transcription_response(Jason.encode!(mock_response))

      assert alternative["transcript"] == "Hello world"
      assert alternative["confidence"] == 0.95
      assert length(alternative["words"]) == 2
    end

    test "successfully parses DeepGram response from map" do
      # Mock Req response as already decoded map
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

      # Test parsing from already decoded map
      assert {:ok, alternative} =
               DeepgramClient.parse_transcription_response(mock_response)

      assert alternative["transcript"] == "Hello world"
      assert alternative["confidence"] == 0.95
      assert length(alternative["words"]) == 2
    end

    test "handles invalid response format from JSON string" do
      invalid_response = %{"results" => %{}}

      assert {:error, "Unexpected response format from DeepGram"} =
               DeepgramClient.parse_transcription_response(Jason.encode!(invalid_response))
    end

    test "handles invalid response format from map" do
      invalid_response = %{"results" => %{}}

      assert {:error, "Unexpected response format from DeepGram"} =
               DeepgramClient.parse_transcription_response(invalid_response)
    end

    test "handles JSON parsing errors" do
      assert {:error, "Failed to parse DeepGram response"} =
               DeepgramClient.parse_transcription_response("invalid json")
    end
  end
end
