defmodule LogbookElixWeb.Router do
  use LogbookElixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: LogbookElixWeb.ApiSpec
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: LogbookElix.Auth.Guardian,
      error_handler: LogbookElixWeb.AuthErrorHandler

    plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/api", LogbookElixWeb do
    pipe_through :api

    # fix this later
    # get "/openapi", OpenApiSpex.Plug.RenderSpec, []

    # Authentication routes (no auth required)
    post "/auth/verify-google-token", AuthController, :verify_google_token
  end

  scope "/api", LogbookElixWeb do
    pipe_through [:api, :auth]

    # Authenticated auth routes
    post "/auth/logout", AuthController, :logout

    resources "/users", UserController, only: [:index, :show, :update]
    resources "/workouts", WorkoutController, except: [:new, :edit]
    resources "/exercises", ExerciseController, except: [:new, :edit]
    resources "/exercise_executions", ExerciseExecutionController, except: [:new, :edit]

    # Transcription endpoint with rate limiting
    post "/transcriptions", TranscriptionController, :create
  end

  # Enable development-only routes
  if Mix.env() in [:dev, :test] do
    # Enable LiveDashboard and Swoosh mailbox preview in development
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: LogbookElixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/api/dev", LogbookElixWeb do
      pipe_through :api

      post "/auth", AuthController, :dev_login
    end
  end
end
