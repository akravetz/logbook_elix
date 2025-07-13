defmodule LogbookElix.Seeds.ExerciseSeederTest do
  use LogbookElix.DataCase
  import LogbookElix.Factory

  alias LogbookElix.Seeds.ExerciseSeeder
  alias LogbookElix.Exercises.Exercise
  alias LogbookElix.Repo

  describe "seed_exercises/0" do
    test "successfully parses and inserts exercises from CSV" do
      # Ensure we start with no exercises
      Repo.delete_all(Exercise)

      assert {:ok, count} = ExerciseSeeder.seed_exercises()
      assert count > 0

      # Check that exercises were actually inserted
      total_exercises = Repo.aggregate(Exercise, :count, :id)
      assert total_exercises == count

      # Verify some specific exercises exist with correct mappings
      bench_press = Repo.get_by(Exercise, name: "Bench Press")
      assert bench_press.body_part == :chest
      assert bench_press.modality == :barbell
      assert bench_press.is_system_created == true
      assert bench_press.created_by_user_id == nil

      # Test body part mapping
      cable_face_pull = Repo.get_by(Exercise, name: "Cable Face Pull")
      # "rear delts" -> :shoulders
      assert cable_face_pull.body_part == :shoulders

      # Test modality mapping
      smith_squat = Repo.get_by(Exercise, name: "Smith Machine Squat")
      assert smith_squat.modality == :smith
    end

    test "skips existing exercises on subsequent runs" do
      # First run
      assert {:ok, initial_count} = ExerciseSeeder.seed_exercises()
      assert initial_count > 0

      # Second run should skip all exercises
      assert {:ok, 0} = ExerciseSeeder.seed_exercises()

      # Total count should remain the same
      total_exercises = Repo.aggregate(Exercise, :count, :id)
      assert total_exercises == initial_count
    end

    test "handles existing exercises with mixed new and duplicate data" do
      # Create one exercise manually
      insert(:exercise, name: "Bench Press", is_system_created: true)

      assert {:ok, count} = ExerciseSeeder.seed_exercises()

      # Should have inserted all except the one that already existed
      total_exercises = Repo.aggregate(Exercise, :count, :id)
      assert total_exercises == count + 1
    end
  end

  describe "body part mapping" do
    test "maps complex body parts to existing schema enums" do
      # Test that the body part mapping works by running the full seeder
      # and checking that exercises with mapped body parts are created correctly
      assert {:ok, _count} = ExerciseSeeder.seed_exercises()

      # Check that exercises with mapped body parts were inserted correctly
      face_pull = Repo.get_by(Exercise, name: "Cable Face Pull")
      # "rear delts" -> :shoulders
      assert face_pull.body_part == :shoulders

      calf_raise = Repo.get_by(Exercise, name: "Calf Raise")
      # "calves" -> :legs
      assert calf_raise.body_part == :legs

      farmers_walk = Repo.get_by(Exercise, name: "Farmer's Walk")
      # "forearms" -> :arms
      assert farmers_walk.body_part == :arms
    end
  end

  describe "modality mapping" do
    test "correctly maps all modality types including SMITH" do
      # Test that smith was properly added to the schema
      valid_modalities = [:barbell, :dumbbell, :cable, :machine, :bodyweight, :smith, :other]

      Enum.each(valid_modalities, fn modality ->
        # Verify each modality is valid by creating an exercise with it
        changeset =
          Exercise.changeset(%Exercise{}, %{
            name: "Test Exercise",
            body_part: :chest,
            modality: modality,
            is_system_created: true
          })

        assert changeset.valid?
      end)
    end
  end
end
