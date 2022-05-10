{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
in
{
  imports = builtins.map mkProject [ "twisto" ];

  projects.kagenova.twisto = {
    enable = true;
    repos.tripping-avenger = {
      url = "https://github.com/TwistoPayments/tripping-avenger.git";
      dest = ".";
      settings.user.email = emails.github;
      ignore = '''';
    };
    extraEnvrc = ''
      [ -e .devshell ] || ln -s ~/personal/dotfiles/projects/data/kagenova/twisto .devshell
      export PRJ_DATA_DIR=$(pwd)/.local/devshell/data
      export PRJ_ROOT=$PWD/.local/devshell
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
      export DJANGO_SETTINGS_MODULE="twisto.settings.development"
      source_env .devshell
    '';
    file.".git/info/exclude".text = ''
      .local/
      .data/
      .cache/
      .envrc
      .vscode/
      .devshell
      .direnv/
      .mypy/
      .mypy_cache/
      .vscodeignore
      .openfortivpn.cfg
      appendonly.aof
      dump.rdb
      pyrightconfig.json
      run.py
    '';
    ipython = ''
      %load_ext autoreload
      %autoreload 2
    '';
  };
}
