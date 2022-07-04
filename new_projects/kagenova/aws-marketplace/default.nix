{ config, lib, ... }: {
  config.workspaces."aws-marketplace" = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/kagelearn/development/aws-marketplace.git";
        settings.user.email = "1085775-mdavezac@users.noreply.gitlab.com";
        exclude = [ "/.envrc" "/.local" ];
      }
    ];
    python.enable = true;
    python.version = "3.10";
    python.packager = "poetry";
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export TFHUB_CACHE_DIR=$PWD/.local/cache/tfhub

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        source_env ~/personal/dotfiles/new_projects/kagenova/aws-marketplace/.envrc
        use flake
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
