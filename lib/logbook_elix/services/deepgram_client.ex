defmodule LogbookElix.Services.DeepgramClient do
  @moduledoc """
  Client for interacting with the DeepGram speech-to-text API.
  """

  require Logger

  @deepgram_api_url "https://api.deepgram.com/v1/listen"
  # 60 seconds for longer audio files
  @timeout 60_000

  @doc """
  Transcribes audio data using DeepGram API.

  Returns simplified transcription from the first channel and alternative.
  """
  def transcribe_audio(audio_data, content_type) do
    api_key = get_api_key()

    headers = [
      {"Authorization", "Token #{api_key}"},
      {"Content-Type", content_type}
    ]

    case HTTPoison.post(@deepgram_api_url, audio_data, headers, recv_timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_transcription_response(body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("DeepGram API error: #{status_code} - #{body}")
        {:error, "DeepGram API error: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, "Failed to connect to DeepGram API"}
    end
  end

  @doc false
  def parse_transcription_response(body) do
    case Jason.decode(body) do
      {:ok, %{"results" => %{"channels" => [%{"alternatives" => [alternative | _]} | _]}}} ->
        {:ok, alternative}

      {:ok, _} ->
        {:error, "Unexpected response format from DeepGram"}

      {:error, _} ->
        {:error, "Failed to parse DeepGram response"}
    end
  end

  defp get_api_key do
    Application.get_env(:logbook_elix, :deepgram_api_key) ||
      System.get_env("DEEPGRAM_API_KEY") ||
      raise "DEEPGRAM_API_KEY not configured"
  end
end
