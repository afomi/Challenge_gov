defmodule Web.SessionView do
  use Web, :view

  def login_gov_enabled? do
    case Application.get_env(:challenge_gov, :oidc_config) do
      %{client_id: client_id} when is_binary(client_id) and client_id != "" -> true
      _ -> false
    end
  end

  def github_enabled? do
    case Application.get_env(:ueberauth, Ueberauth.Strategy.Github.OAuth) do
      config when is_list(config) ->
        client_id = Keyword.get(config, :client_id)
        is_binary(client_id) and client_id != ""

      _ ->
        false
    end
  end
end
