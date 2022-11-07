{ config, lib, pkgs, ... }:
let
  emails.github = "2745737+mdavezac@users.noreply.github.com";
in
{
  config.workspaces.neovim = {
    enable = true;
    root = "personal";
    repos = [
      {
        url = "github:neovim/neovim";
        settings.user.email = emails.github;
        exclude = [ "/.local" ];
        destination = ".";
      }
    ];
    python.enable = false;
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        PATH_add .local/bin/

        use flake ./contrib
      ''
    ];
  };
}
