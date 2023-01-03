{ config, lib, pkgs, ... }: {
  config.workspaces.astro-informatics = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "github:astro-informatics/ssht.git";
        settings.user.email = config.emails.github;
        destination = "ssht";
      }
      {
        url = "github:mdavezac/conan-center-index.git";
        destination = "conan-center-index";
        settings.user.email = config.emails.github;
      }
    ];
    python.enable = true;
    python.version = "3.8";
    python.packager = "pip";
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        [ -e .local/flake ] || ln -s ~/personal/dotfiles/new_projects/kagenova/packaging .local/flake
        source_env .local/flake/.envrc
      ''
    ];
    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import re
      from pathlib import Path
      from textwrap import dedent
      rng = np.random.default_rng()
    '';
  };
}
