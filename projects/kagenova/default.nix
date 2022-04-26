{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
in
{
  imports = (
    builtins.map mkProject [
      "tensossht"
      "learn"
      "website"
      "alignment"
      "puzzles"
      "aws-marketplace"
    ] ++ [
      ./packaging.nix
      ./copernic360.nix
      ./move.nix
      ./blockchain.nix
      ./consulting.nix
    ]
  );

  # tensossht: {{{
  projects.kagenova.tensossht = {
    enable = true;
    repos =
      let
        kagelearn_url = "gitlab.com/kagenova/kagelearn/development";
      in
      {
        tensossht = {
          url = "https://${kagelearn_url}/tensossht.git";
          dest = ".";
          settings = { user.email = emails.gitlab; };
          ignore = '''';
        };
      };
    file.".git/info/exclude".text = ''
      .vim/
      .local/
      .envrc
      .vscode/
      shell.nix
    '';
    extraEnvrc = ''
      check_precommit
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
      PATH_add .local/bin/
      export PRJ_DATA_DIR=$PWD/.local/devshell/data
      export PRJ_ROOT=$PWD/.local/devshell
      source_env_if_exists $PWD/.local/nvim/envrc
      source_env_if_exists $PWD/.envrc.flake
    '';
    ipython = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import tensorflow as tf
    '';
  };
  # }}}

  # learn: {{{
  projects.kagenova.learn = {
    enable = true;
    repos.learn = {
      url = "https://gitlab.com/kagenova/kagelearn/development/kagelearn.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .local/
        .envrc
        TODOs.org
      '';
    };
    extraEnvrc = ''
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
      eval "$(lorri direnv)"
      layout poetry python3.6
      extra_pip_packages pdbpp ipython jupyter rstcheck
      check_precommit
    '';
  };
  # }}}

  # website: {{{
  projects.kagenova.website = {
    enable = true;
    repos.web = {
      url = "https://gitlab.com/kagenova/marketing/website.git";
      dest = ".";
      settings.user.email = emails.gitlab;
    };
    extraEnvrc = ''
      layout python3
      packages=$(python -m pip freeze)
      for package in ipython; do
          [[ "$packages" == *"$package"* ]] \
            || python -m pip install $package
      done
      source_env_if_exists $PWD/.local/nvim/envrc
    '';
    nixshell = {
      text = ''
        buildInputs = [
          (ruby.withPackages (p: with p; [bundler jekyll]))
          python38
          google-cloud-sdk
        ];
      '';
    };
    vim = ''
      set textwidth=88
      set colorcolumn=89
      let g:neomake_python_enabled_makers = ["flake8"]
      let g:neoformat_enabled_python = ["isort", "docformatter", "black"]
      let g:neoformat_python_docformatter.args = [
        \ '--wrap-descriptions', 88,
        \ '--wrap-summaries', 88,
        \ '-' ]
    '';
  };
  # }}}

  # cdt: {{{
  projects.kagenova.alignment = {
    enable = true;
    repos.learn = {
      url = "https://gitlab.com/kagenova/kagelearn/development/alignment.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .local/
        .envrc
        TODOs.org
      '';
    };
    extraEnvrc = ''
      eval "$(lorri direnv)"
      layout poetry 3.7
      check_precommit
      export PULUMI_HOME=$(pwd)/.local/pulumi;
      [ -e TODOs.org ] || ln -s ~/org/cdt.org TODOs.org
    '';
    coc = {
      "pyls.enable" = false;
      "python.linting.enabled" = true;
      "python.linting.mypyEnabled" = false;
      "python.linting.flake8Enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.jediEnabled" = false;
      "python.formatting.provider" = "black";
      "codeLens.enable" = true;
      "diagnostic.enable" = true;
      "diagnostic.virtualText" = true;
    };
  };
  # }}}

  # puzzles: {{{
  projects.kagenova.puzzles = {
    enable = true;
    repos =
      {
        puzzles = {
          url = "https://gitlab.com/kagenova/internal/tools-practice/google-code-jam";
          dest = ".";
          settings = { user.email = emails.gitlab; };
          ignore = ''
            .vim/
            .local/
            .envrc
            .vscode/
          '';
        };
      };
    extraEnvrc = ''layout python3'';
  };
  # }}}

  # aws-marketplace: {{{
  projects.kagenova.aws-marketplace = {
    enable = true;
    extraEnvrc = ''
      check_precommit
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
      PATH_add .local/bin/
      export PRJ_DATA_DIR=$PWD/.local/devshell/data
      export PRJ_ROOT=$PWD/.local/devshell
      source_env_if_exists $PWD/.local/nvim/envrc
      source_env_if_exists $PWD/.envrc.flake
      use flake
      use poetry
    '';
    ipython = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
      import tensorflow as tf
    '';
  };
  # }}}
}
