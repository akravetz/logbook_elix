We want to implement a dev auth controller that takes a username and simply creates the user and returns the JWT token. To denote dev users, the email should be saved to the db as `dev:<email>`.

The objective is to make the backend easy to test in dev using curl.
This endpoint should only be available in the dev environment

I have not thought this through deeply so make sure you ask any clarifying questions