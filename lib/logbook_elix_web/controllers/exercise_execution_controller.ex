defmodule LogbookElixWeb.ExerciseExecutionController do
  use LogbookElixWeb, :controller

  alias LogbookElix.Executions
  alias LogbookElix.Executions.ExerciseExecution

  action_fallback LogbookElixWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    exercise_executions = Executions.list_exercise_executions(user.id)
    render(conn, :index, exercise_executions: exercise_executions)
  end

  def create(conn, %{"exercise_execution" => exercise_execution_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %ExerciseExecution{} = exercise_execution} <-
           Executions.create_exercise_execution(exercise_execution_params, user.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/exercise_executions/#{exercise_execution}")
      |> render(:show, exercise_execution: exercise_execution)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, exercise_execution} <- Executions.get_exercise_execution(id, user.id) do
      render(conn, :show, exercise_execution: exercise_execution)
    end
  end

  def update(conn, %{"id" => id, "exercise_execution" => exercise_execution_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %ExerciseExecution{} = exercise_execution} <-
           Executions.update_exercise_execution(id, exercise_execution_params, user.id) do
      render(conn, :show, exercise_execution: exercise_execution)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %ExerciseExecution{}} <- Executions.delete_exercise_execution(id, user.id) do
      send_resp(conn, :no_content, "")
    end
  end
end
