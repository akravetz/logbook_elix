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
    # Skip header row
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
    existing_names = get_existing_exercise_names()

    new_exercises =
      exercises
      |> Enum.reject(fn exercise -> exercise.name in existing_names end)

    case insert_new_exercises(new_exercises) do
      {:ok, inserted_count} ->
        total_count = length(exercises)
        skipped_count = total_count - inserted_count

        IO.puts("Exercise seeding completed:")
        IO.puts("  - #{inserted_count} new exercises inserted")
        IO.puts("  - #{skipped_count} exercises skipped (already exist)")
        IO.puts("  - #{total_count} total exercises in CSV")

        {:ok, inserted_count}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_existing_exercise_names do
    from(e in Exercise, select: e.name)
    |> Repo.all()
  end

  defp insert_new_exercises(exercises) do
    try do
      results =
        exercises
        |> Enum.map(fn exercise_attrs ->
          %Exercise{}
          |> Exercise.changeset(exercise_attrs)
          |> Repo.insert()
        end)

      failed_inserts =
        Enum.filter(results, fn
          {:error, _} -> true
          _ -> false
        end)

      if Enum.empty?(failed_inserts) do
        {:ok, length(exercises)}
      else
        error_count = length(failed_inserts)
        {:error, "#{error_count} exercises failed to insert"}
      end
    rescue
      exception ->
        {:error, "Exception during exercise insertion: #{Exception.message(exception)}"}
    end
  end
end
