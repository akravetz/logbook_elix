# High Level

Get Swole is a web app that is used to manage and track workouts for weightlifters/bodybuilders and people generally using progressive overload. The main functionality is adding workouts and adding custom exercises. The application comes pre-loaded with a long list of standard, pre-existing exercises.

# Tech Stack
## Backend
- Elixer + Phoenix
- postgres database
- deployed on fly.io
- ecto for migrations
- credo for static analysis
- OpenApiSpex to generate an OpenAPI spec which is used by orval to generate the frontend API typescript code

## Frontend
- React (latest stable version of React 19)
- auth.js for authentication against google oauth
- TanStack Router
- shadcn + tailwind for ui elements
- orval for API code gen
- Zustand object store
- ESLint for static analysis
- Vite build manager
- npm for package management
- deployed on vercel.com

# Authentication
Authentication is handled largely by the frontend. The frontend will handle the entire google oauth flow. The access token that is returned by google oauth is passed to the backend via an API call. The API call is responsible for taking the access token, verifying it using the google token verification endpoint, and then returning a JWT access token that is then used by the frontend for future API calls.

# Backend Description
The backend is a simple collection of CRUD API endpoints.  The only endpoints that can be accessed without a valid JWT token are the verify-google-token endpoint.  This endpoint takes a google access token and verifies it (see Authentication section).  Upon success the user is looked up in the User schema based on their email address. If the user does not exist, one is created based on information from the google profile.

From there, the only API endpoints are CRUD endpoints for workouts and exercise executions, a list endpoint for exercises, and a logout functionality.

In order to avoid handling refresh tokens, the JWT has a very long expiration (3 hours)

# Frontend Description
For users who are not logged in, the login page is a simple "Login with Google" button as well as some basic copy.

Once logged in, the layout should have a header that displays the users profile picture + name on all pages. It will also have a footer that has: "profile" "workouts" and "exercises" "ask AI". After logging in, the user is defaulted to the workout page. 

The interface should be clean and simple. It should utilize spacing, contrast, and size to do all of the heavy lifting. The most important user story to support is: "I want to create a new work out, add exercises and sets as I complete them, and then finish the workout to log it" The is supported via the following flow: 1. user goes to workouts page 2. clicks "new workout" 3. starts an empty workout 4. user adds exercises one by one - selecting the exercise from a list of known exercises 5. after adding an exercise, the user will add a set (weight, number of clean reps, number of forced reps - diplayed in the form of [N lb] x [N clean reps] + [N forced reps] 6. they will update a set in case they made a mistake 7. they will be able to reorder exercises 8. if the exercise they are performing does not exist in the database, the user can add a new exercise and provide the bodypart (arms, shoulders, back, chest, legs) and the modality (dumbbell, barbell, cable, machine, bodyweight) 8. once the workout is complete they click "finish" and the workout is completed.