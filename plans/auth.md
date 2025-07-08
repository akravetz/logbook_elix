Implement backend authentication as described in @docs/project_plan.md 
Use Guardian
Create two new endpoints:
1. verify token endpoint that verifies the google user token using verification module you implemented.  This endpoint then creates a new user if a user with the associated email does not exist.  It then returns a JWT token that the frontend can use in later api calls.

2. logout


Use guardian to ensure all endpoints except the verify token endpoint and the logout endpoint.

You will have to refactor the controller tests since they will now be protected by Guardian.  To refactor these tests:

Use a Centralized Test Helper for Authentication
This approach involves creating or modifying a test helper module that all your API tests can leverage. This helper would provide functions to automatically authenticate and include the necessary tokens in your test requests.

ex:
```
# test/support/auth_test_helper.ex
defmodule YourAppWeb.AuthTestHelper do
  def authenticated_conn(conn) do
    user = insert(:user) # Use ExMachina to create a user
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

    conn
    |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
```