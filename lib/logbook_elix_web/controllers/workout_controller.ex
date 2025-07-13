defmodule LogbookElixWeb.WorkoutController do
  use LogbookElixWeb, :controller

  alias LogbookElix.Workouts
  alias LogbookElix.Workouts.Workout

  action_fallback LogbookElixWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    workouts = Workouts.list_workouts(user.id)
    render(conn, :index, workouts: workouts)
  end

  def create(conn, %{"workout" => workout_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Workout{} = workout} <- Workouts.create_workout(workout_params, user.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/workouts/#{workout}")
      |> render(:show, workout: workout)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, workout} <- Workouts.get_workout(id, user.id) do
      render(conn, :show, workout: workout)
    end
  end

  def update(conn, %{"id" => id, "workout" => workout_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Workout{} = workout} <- Workouts.update_workout(id, workout_params, user.id) do
      render(conn, :show, workout: workout)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Workout{}} <- Workouts.delete_workout(id, user.id) do
      send_resp(conn, :no_content, "")
    end
  end
end
