{ config, lib, pkgs, ... }:
let
  emails = {
    gitlab = "1085775-mdavezac@users.noreply.gitlab.com";
    github = "2745737+mdavezac@users.noreply.github.com";
  };
in
{
  config.workspaces.tensossht = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/kagelearn/development/tensossht.git";
        settings.user.email = emails.gitlab;
        exclude = [ "/.local" ];
        destination = ".";
      }
    ];
    python.enable = true;
    python.version = "3.8";
    python.packager = "poetry";
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export TFHUB_CACHE_DIR=$PWD/.local/cache/tfhub

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        PATH_add .local/bin/

        [ -e  .local/nvim ] || ln -s ~/personal/dotfiles/new_projects/kagenova/tensossht .local/nvim
        source_env .local/nvim/.envrc

        source_env_if_exists $PWD/.envrc.flake
      ''
    ];
    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import tensorflow as tf
    '';
  };
}
