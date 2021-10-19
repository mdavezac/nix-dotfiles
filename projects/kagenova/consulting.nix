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
      source_env .devshell
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
    '';
    file.".git/info/exclude".text = ''
      .local/
      .data/
      .cache/
      .envrc
      .vscode/
      .devshell
    '';
  };
}
