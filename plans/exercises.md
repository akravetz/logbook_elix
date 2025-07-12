We need to create an exercises schema + endpoints.
use `phx.gen.json`

we will need a create, update, read, delete, and list endpoint. all endpoints will be protected by guardian

schema is as follows:

name
body part (enum: chest, back, legs, arms, core, shoulders, quads, glutes, hamstrings)
modality (enum: barbell, dumbbell, cable, machine, bodyweight, other)
created by user id (fk to user id)
is system created (true if system generated, false otherwise)

after the schema + controller is generated:
- a user should only be able to delete + update their own exercises
- user should only be able to read their own exercises + system create exercises
- the list endpoint should return all exercises where is_system_created = TRUE or created by current user

We do not need to maintain backwards compatibility. Update exercise execution to refer to the exercises schema