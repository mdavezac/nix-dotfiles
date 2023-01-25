{
  config,
  lib,
  pkgs,
  ...
}: {
  config.workspaces.copernicai = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "gitlab:kagenova/kagelearn/development/copernicai.git";
        settings.user.email = config.emails.gitlab;
        exclude = ["/.local" "/.envrc" "/.devenv/" "/dist/"];
        destination = ".";
      }
    ];
    python.enable = true;
    python.version = "3.8";
    python.packager = "poetry";
    envrc = [
      ''
        flakedir=~/personal/dotfiles/new_projects/kagenova/copernicai
        [ -e  .local/flake ] || ln -s $flakedir .local/flake
        use flake $flakedir

        export IPYTHONDIR=$PWD/.local/ipython/
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
