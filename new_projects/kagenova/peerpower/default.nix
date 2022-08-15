{ config, lib, pkgs, ... }:
let
  emails = {
    gitlab = "1085775-mdavezac@users.noreply.gitlab.com";
    github = "2745737+mdavezac@users.noreply.github.com";
  };
in
{
  config.workspaces."peerpower" = {
    enable = true;
    root = "kagenova";
    repos = [
      {
        url = "github:peerpower/risk_ocr_engine.git";
        settings.user.email = emails.github;
        exclude = [
          "/.envrc"
          "/.local/"
          "/.direnv/"
          "/.dockerignore"
          "/pyproject.toml"
        ];
        destination = ".";
      }
      {
        url = "github:peerpower/risk_bank_statement_analysis_service.git";
        settings.user.email = emails.github;
        exclude = [ "/.envrc" "/.local/" "/.direnv/" "/.dockerignore" "/pyproject.toml" "/scratch.py" ];
        destination = "version2";
      }
    ];
    python.enable = false;
    python.version = "3.10";
    python.packager = "pip";
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell
        export IPYTHONDIR=$PWD/.local/ipython/
        export AWS_CONFIG_FILE=$PWD/.local/aws/config
        export AWS_SHARED_CREDENTIALS_FILE=$PWD/.local/aws/credentials
        export PASSWORD_STORE_DIR=$PWD/.local/passwords

        mkdir -p $(dirname $AWS_CONFIG_FILE)
        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT
        path_add PYTHONPATH $PWD/app $PWD/version2/app # $PWD/.local/pip

        [ -e  .local/flake ] || ln -s ~/personal/dotfiles/new_projects/kagenova/peerpower .local/flake
        source_env .local/flake/.envrc
      ''
    ];
    file.".local/ipython/profile_default/startup/startup.ipy".text = ''
      %load_ext autoreload
      %autoreload 2

      import numpy as np
    '';

    file.".local/aws/config".text = ''
      [profile peerpower-mayeul]
      region = "ap-southeast-1"
    '';
    file.".dockerignore".text = ''
      *
      !/app
      !/db_snapshot_json
      !requirements.txt
      !/test
    '';
    file."pyproject.toml".text = ''
      [tool.isort]
      profile = "black"
    '';
  };
}
