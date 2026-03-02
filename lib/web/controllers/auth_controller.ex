defmodule Web.AuthController do
  use Web, :controller

  plug Ueberauth

  alias ChallengeGov.Accounts
  alias ChallengeGov.Security

  def request(conn, _params) do
    # Ueberauth handles the redirect to GitHub automatically
    conn
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    github_uid = to_string(auth.uid)
    email = auth.info.email

    case Accounts.map_from_github(github_uid, email, Security.extract_remote_ip(conn)) do
      {:ok, user} ->
        conn
        |> put_session(:user_token, user.token)
        |> put_session(
          :session_timeout_at,
          Web.SessionController.new_session_timeout_at(Security.timeout_interval())
        )
        |> Web.SessionController.after_sign_in_redirect(Routes.dashboard_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "There was an issue logging in with GitHub")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _failure}} = conn, _params) do
    conn
    |> put_flash(:error, "GitHub authentication failed")
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
