{ config, lib, pkgs, ... }:
let
  emails = {
    gitlab = "1085775-mdavezac@users.noreply.gitlab.com";
    github = "2745737+mdavezac@users.noreply.github.com";
  };
in
{
  config.workspaces."aws-marketplace" = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/copernicai/aws-marketplace.git";
        settings.user.email = emails.gitlab;
        exclude = [
          "/.envrc"
          "/.local"
          "/tutorial"
          "/content.jpg"
          "imagenet_resnet_v1_50_classification_5.tar.gz"
          "/images/"
          "/labels.csv"
          "/labels.txt"
          "/out.jpg"
          "/validation/"
          "/values.csv"
        ];
        destination = ".";
      }
      {
        url = "gitlab:kagenova/copernicai/aws-marketplace-tutorial";
        settings.user.email = emails.gitlab;
        destination = "tutorial";
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

        use flake
        [ -e  .local/nvim ] || ln -s ~/personal/dotfiles/new_projects/kagenova/aws-marketplace .local/nvim
        source_env .local/nvim/.envrc
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
