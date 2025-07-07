## data models for the backend

User
  email_address :string
  google_id :string # NOTE: we will build support for google oauth into the frontend. On the backend we will simplify verify the access token returned to the frontend using the google verification api, and if correct, return a JWT token
  name :string
  profile_image_url :string
  is_active :boolean, default: true

Workout
  user_id: int (fk)
  finished_at :utc_datetime
  exercises (list of exercises)

ExerciseExecution
  workout_id (fk)
  exercise :int
  note :string
  exercise_order :int # exercises are executed in an order 1 through N
  sets (list of sets)

Set
  exercise_id (fk)
  weight, :float
  clean_reps, :integer
  forced_reps, :integer, default: 0