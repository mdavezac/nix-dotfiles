{ config
, lib
, pkgs
, ...
}: {
  config.workspaces.sparse-dense-tests = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/kagelearn/development/sparse-dense-tests";
        settings.user.email = config.emails.gitlab;
        exclude = [ "/.local" ];
        destination = ".";
      }
    ];
    envrc = [
      ''
        mkdir -p .local
        [ -e  .local/nvim ] || ln -s ~/personal/dotfiles/new_projects/personal/sparse-dense-tests .local/nvim
        source_env .local/nvim/.envrc

        use flake --impure

        export POETRY_VIRTUALENVS_PATH=$PWD/.local/poetry/venvs
        layout poetry 3.10
      ''
    ];
  };
}
