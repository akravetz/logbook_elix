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

    case Req.post(@deepgram_api_url,
           body: audio_data,
           headers: headers,
           receive_timeout: @timeout
         ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        parse_transcription_response(body)

      {:ok, %Req.Response{status: status_code, body: body}} ->
        body_str = if is_binary(body), do: body, else: Jason.encode!(body)
        Logger.error("DeepGram API error: #{status_code} - #{body_str}")
        {:error, "DeepGram API error: #{status_code}"}

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, "Failed to connect to DeepGram API"}
    end
  end

  @doc false
  def parse_transcription_response(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, data} -> parse_transcription_data(data)
      {:error, _} -> {:error, "Failed to parse DeepGram response"}
    end
  end

  def parse_transcription_response(body) when is_map(body) do
    parse_transcription_data(body)
  end

  defp parse_transcription_data(%{
         "results" => %{"channels" => [%{"alternatives" => [alternative | _]} | _]}
       }) do
    {:ok, alternative}
  end

  defp parse_transcription_data(_) do
    {:error, "Unexpected response format from DeepGram"}
  end

  defp get_api_key do
    Application.get_env(:logbook_elix, :deepgram_api_key) ||
      System.get_env("DEEPGRAM_API_KEY") ||
      raise "DEEPGRAM_API_KEY not configured"
  end
end
