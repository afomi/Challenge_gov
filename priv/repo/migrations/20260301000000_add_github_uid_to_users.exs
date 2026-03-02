defmodule ChallengeGov.Repo.Migrations.AddGithubUidToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :github_uid, :string
    end

    create unique_index(:users, [:github_uid])
  end
end
