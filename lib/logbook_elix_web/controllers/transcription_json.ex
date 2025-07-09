defmodule LogbookElixWeb.TranscriptionJSON do
  @doc """
  Renders transcription data.
  """
  def data(%{transcription: transcription}) do
    %{
      data: %{
        transcript: transcription["transcript"],
        confidence: transcription["confidence"],
        words: render_words(transcription["words"] || [])
      }
    }
  end

  defp render_words(words) do
    Enum.map(words, fn word ->
      %{
        word: word["word"],
        start: word["start"],
        end: word["end"],
        confidence: word["confidence"]
      }
    end)
  end
end
