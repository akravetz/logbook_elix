# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LogbookElix.Repo.insert!(%LogbookElix.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias LogbookElix.Seeds.ExerciseSeeder

# Seed exercises from CSV
case ExerciseSeeder.seed_exercises() do
  {:ok, count} ->
    IO.puts("Successfully seeded #{count} exercises")

  {:error, reason} ->
    IO.puts("Failed to seed exercises: #{reason}")
    System.halt(1)
end
