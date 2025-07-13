defmodule LogbookElix.Seeds.ExerciseSeeder do
  @moduledoc """
  Seeds exercises from CSV file into the database.
  """

  import Ecto.Query, warn: false
  alias LogbookElix.Repo
  alias LogbookElix.Exercises.Exercise
  alias NimbleCSV.RFC4180, as: CSV

  @csv_path "priv/repo/seeds/exercises.csv"

  @doc """
  Seeds exercises from the CSV file.
  Returns {:ok, count} on success or {:error, reason} on failure.
  """
  def seed_exercises do
    case File.read(@csv_path) do
      {:ok, csv_content} ->
        exercises = parse_exercises(csv_content)
        insert_exercises(exercises)

      {:error, reason} ->
        {:error, "Failed to read CSV file: #{reason}"}
    end
  end

  defp parse_exercises(csv_content) do
    csv_content
    |> CSV.parse_string(skip_headers: false)
    |> Enum.drop(1)
    |> Enum.map(&parse_exercise_row/1)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_exercise_row([name, body_part, modality]) do
    %{
      name: String.trim(name),
      body_part: map_body_part(String.trim(body_part)),
      modality: map_modality(String.trim(modality)),
      is_system_created: true,
      created_by_user_id: nil
    }
  end

  defp parse_exercise_row(_), do: nil

  defp map_body_part("rear delts"), do: :shoulders
  defp map_body_part("calves"), do: :legs
  defp map_body_part("forearms"), do: :arms
  defp map_body_part("lower back"), do: :back
  defp map_body_part("full body"), do: :full_body
  defp map_body_part("quads"), do: :legs
  defp map_body_part("hamstrings"), do: :legs
  defp map_body_part("glutes"), do: :legs
  defp map_body_part("biceps"), do: :arms
  defp map_body_part("triceps"), do: :arms
  defp map_body_part("traps"), do: :shoulders

  defp map_body_part(body_part) do
    downcased = String.downcase(body_part)

    case downcased do
      "chest" -> :chest
      "back" -> :back
      "legs" -> :legs
      "arms" -> :arms
      "core" -> :core
      "shoulders" -> :shoulders
      _ -> :other
    end
  end

  defp map_modality("SMITH"), do: :smith

  defp map_modality(modality) do
    downcased = String.downcase(modality)

    case downcased do
      "barbell" -> :barbell
      "dumbbell" -> :dumbbell
      "cable" -> :cable
      "machine" -> :machine
      "bodyweight" -> :bodyweight
      "smith" -> :smith
      _ -> :other
    end
  end

  defp insert_exercises(exercises) do
    existing_names = get_existing_exercise_names() |> MapSet.new()

    new_exercises =
      exercises
      |> Enum.reject(fn exercise -> MapSet.member?(existing_names, exercise.name) end)

    insert_new_exercises(new_exercises)
  end

  defp get_existing_exercise_names do
    from(e in Exercise, select: e.name)
    |> Repo.all()
  end

  defp insert_new_exercises(exercises) do
    if Enum.empty?(exercises) do
      {:ok, 0}
    else
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      exercise_entries =
        Enum.map(exercises, fn attrs ->
          Map.merge(attrs, %{
            inserted_at: now,
            updated_at: now
          })
        end)

      case Repo.insert_all(Exercise, exercise_entries) do
        {count, _} -> {:ok, count}
      end
    end
  end
end
