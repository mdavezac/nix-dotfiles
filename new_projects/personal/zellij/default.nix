{ config, lib, pkgs, ... }:
let
  emails.github = "2745737+mdavezac@users.noreply.github.com";
in
{
  config.workspaces.zellij = {
    enable = true;
    root = "personal";
    repos = [
      {
        url = "github:mdavezac/zellij";
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

        [ -e  .local/nvim ] || ln -s ~/personal/dotfiles/new_projects/personal/zellij .local/nvim
        source_env .local/nvim/.envrc

        use flake
      ''
    ];
  };
}
