defmodule LogbookElixWeb.TranscriptionController do
  use LogbookElixWeb, :controller

  alias LogbookElix.Services.DeepgramClient

  action_fallback LogbookElixWeb.FallbackController

  # Maximum audio file size in bytes (100MB)
  @max_audio_size 100_000_000

  # Apply rate limiting specifically to the create action
  plug LogbookElixWeb.Plugs.RateLimiter,
       [
         limit: 10,
         window_ms: 60_000,
         bucket_prefix: "transcription"
       ]
       when action in [:create]

  @doc """
  Creates a transcription from uploaded audio file.

  Accepts audio data in the request body with appropriate Content-Type header.
  """
  def create(conn, _params) do
    content_type = get_req_header(conn, "content-type") |> List.first()

    with {:ok, content_type} <- validate_content_type(content_type),
         {:ok, audio_data, conn} <- read_audio_body(conn),
         {:ok, transcription} <- DeepgramClient.transcribe_audio(audio_data, content_type) do
      conn
      |> put_status(:ok)
      |> json(%{
        data: %{
          transcript: transcription["transcript"],
          confidence: transcription["confidence"],
          words: transcription["words"] || []
        }
      })
    end
  end

  defp validate_content_type(nil), do: {:error, "Content-Type header is required"}

  defp validate_content_type(content_type) do
    valid_types = ["audio/wav", "audio/mp3", "audio/m4a", "audio/webm", "audio/mpeg"]

    if Enum.any?(valid_types, &String.starts_with?(content_type, &1)) do
      {:ok, content_type}
    else
      {:error, "Invalid content type. Supported formats: wav, mp3, m4a, webm"}
    end
  end

  defp read_audio_body(conn) do
    case Plug.Conn.read_body(conn, length: @max_audio_size) do
      {:ok, body, conn} ->
        {:ok, body, conn}

      {:more, _partial_body, _conn} ->
        {:error, "Audio file too large. Maximum size is 100MB"}

      {:error, _reason} ->
        {:error, "Failed to read audio data"}
    end
  end
end
