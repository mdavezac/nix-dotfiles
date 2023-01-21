{ config
, lib
, pkgs
, ...
}: {
  config.workspaces.copernicai = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/kagelearn/development/copernicai.git";
        settings.user.email = config.emails.gitlab;
        exclude = [ "/.local" ];
        destination = ".";
      }
    ];
    python.enable = true;
    python.version = "3.8";
    python.packager = "poetry";
    envrc = [
      ''
        [ -e  .local/flake ] || ln -s ~/personal/dotfiles/new_projects/kagenova/copernicai .local/flake
        source_env .local/flake/.envrc

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
