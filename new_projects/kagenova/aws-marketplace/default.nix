{ config, lib, ... }: {
  config.workspaces."aws-marketplace" = {
    enable = true;
    root = "new_projects";
    repos = [
      {
        url = "github:mdavezac/spglib.jl";
        settings.user.email = "2745737+mdavezac@users.noreply.github.com";
        exclude = [ "/.envrc" "/.local" ];
      }
    ];
    python.enable = true;
    python.version = "3.10";
    python.packager = "poetry";
    envrc = [
      "export PRJ_DATA_DIR=$PWD/.local/devshell/data"
      "export PRJ_ROOT=$PWD/.local/devshell"
      "mkdir -p $PRJ_DATA_DIR"
      "mkdir -p $PRJ_ROOT"
      "source_env ~/personal/dotfiles/new_projects/kagenova/aws-marketplace/.envrc"
    ];
  };
}
