defmodule LogbookElixWeb.ExerciseController do
  use LogbookElixWeb, :controller

  alias LogbookElix.Exercises
  alias LogbookElix.Exercises.Exercise
  alias LogbookElix.Auth.Guardian

  action_fallback LogbookElixWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    exercises = Exercises.list_exercises(user.id)
    render(conn, :index, exercises: exercises)
  end

  def create(conn, %{"exercise" => exercise_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Exercise{} = exercise} <- Exercises.create_exercise(exercise_params, user.id) do
      conn
      |> put_status(:created)
      |> render(:show, exercise: exercise)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, exercise} <- Exercises.get_exercise(id, user.id) do
      render(conn, :show, exercise: exercise)
    end
  end

  def update(conn, %{"id" => id, "exercise" => exercise_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Exercise{} = exercise} <- Exercises.update_exercise(id, exercise_params, user.id) do
      render(conn, :show, exercise: exercise)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Exercise{}} <- Exercises.delete_exercise(id, user.id) do
      send_resp(conn, :no_content, "")
    end
  end
end
