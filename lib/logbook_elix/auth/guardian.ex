defmodule LogbookElix.Auth.Guardian do
  use Guardian, otp_app: :logbook_elix

  alias LogbookElix.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
