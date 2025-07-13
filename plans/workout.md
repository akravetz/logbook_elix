We implemented appropriate user-level protection in Exercises. We need to implement a similar pattern for Workouts and Executions.

- when these objects are created, the user_id should be taken from the authentication context
- a user should only be able to read + update + delete their own workouts and executions
- tests may need to be updated appropriately