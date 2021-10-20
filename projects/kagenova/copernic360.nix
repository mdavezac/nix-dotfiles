{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
  utils = (pkgs.callPackage (import ../lib/utils.nix) { });
  starsets = {
    nix_shell.disabled = true;
    package.disabled = true;
    python = {
      disabled = false;
      format = ''via [$symbol$version]($style) '';
    };
    gcloud = {
      disabled = false;
      format = "[$symbol$active]($style) ";
      symbol = "💭 ";
    };
    aws = {
      disabled = false;
      format = "[$symbol$profile]($style) ";
      symbol = "🅰 ";
    };
  };
in
{
  imports = (
    builtins.map mkProject [
      "copernic360"
      "ai-pipeline"
    ]
  );

  projects.kagenova.copernic360 = {
    enable = false;
    repos.copernic360 = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-webapi.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .vscode/
        .local/
        .envrc
        TODOs.org
        copernic360.code-workspace
      '';
    };
    extraEnvrc = ''
      eval "$(lorri direnv)"
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
      layout poetry 3.7
      check_precommit
      export STARSHIP_CONFIG=${utils.starship_conf starsets}
      [ -e TODOs.org ] || ln -s ~/org/copernic360.org TODOs.org
    '';
    file."copernic360.code-workspace".source = utils.toPrettyJSON {
      folders = [
        { path = "."; }
        { path = "../ai-pipeline"; }
      ];
      settings = {
        "python.venvPath" = "\${workspaceFolder}/.local/venvs";
      };
    };
  };

  home.file.".config/gcloud/configurations/config_copernic360-development".text = lib.generators.toINI { } {
    core = {
      account = "pulumi-deployment@spatial360-development.iam.gserviceaccount.com";
      project = "spatial360-development";
    };
  };
  home.file.".config/gcloud/configurations/config_copernic360-staging".text = lib.generators.toINI { } {
    core = {
      account = "pulumi-deployment@spatial360-staging.iam.gserviceaccount.com";
      project = "spatial360-staging";
    };
  };
  home.file.".config/gcloud/configurations/config_copernic360-production".text = lib.generators.toINI { } {
    core = {
      account = "pulumi-deployment@spatial360-production.iam.gserviceaccount.com";
      project = "spatial360-production";
    };
  };

  # ai-pipeline: {{{
  projects.kagenova.ai-pipeline = {
    enable = true;
    repos.pipeline = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/data-pipeline.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .vscode/
        .local/
        .envrc
        TODOs.org
        ai-pipeline.code-workspace
      '';
    };
    extraEnvrc = ''
      eval "$(lorri direnv)"
      export POETRY_VIRTUALENVS_PATH=$(pwd)/.local/venvs
      layout poetry 3.7
      check_precommit
      export STARSHIP_CONFIG=${utils.starship_conf starsets}
      export PULUMI_HOME=$(pwd)/.local/pulumi;
      export COMPOSE_FILE=$(pwd)/.docker/docker-compose.yml
      [ -e TODOs.org ] || ln -s ~/org/copernic360.org TODOs.org
    '';
    file."ai-pipeline.code-workspace".source = utils.toPrettyJSON {
      folders = [
        { path = "."; }
      ];
      settings = {
        "python.venvPath" = "\${workspaceFolder}/.local/venvs";
        "workbench.colorTheme" = "Community Material Theme Darker High Contrast";
        "nixEnvSelector.nixFile" = "\${workspaceFolder}/shell.nix";
      };
    };
    file.".local/bin/switch_stack.fish".text = ''
      function switch_stack -a arg
          set -e AWS_PROFILE
          set -e SQL_PASSWORD
          set -e SQL_USERNAME
          set -e SQL_PORT
          set -e GOOGLE_APPLICATION_CREDENTIALS
          set -e COPERNIC360_HOST
          set -e PYTEST_PULUMI_STACK
          set -e AWS_REGION
          set -gx SQL_DATABASE spatial360_api
          set local_pwd "/Users/mdavezac/kagenova/ai-pipeline/"
          set stack $arg
          switch $arg
              case development
                  set gcp_config development
                  set aws_profile development
                  set puldir $local_pwd/infrastructure
              case bootstrap
                  set gcp_config development
                  set stack bootstrap
                  set aws_profile development
                  set puldir $local_pwd/bootstrap
              case monitoring-development
                  set gcp_config development
                  set stack development
                  set aws_profile monitoring-development
                  set puldir $local_pwd/infrastructure
              case staging
                  set gcp_config staging
                  set aws_profile staging
                  set puldir $local_pwd/infrastructure
              case bootstrap-staging
                  set gcp_config staging
                  set aws_profile staging
                  set puldir $local_pwd/bootstrap
              case bootstrap
                  set gcp_config production
                  set aws_profile production
                  set puldir $local_pwd/infrastructure
              case bootstrap-production
                  set gcp_config production
                  set aws_profile production
                  set puldir $local_pwd/bootstrap
              case production
                  set gcp_config production
                  set aws_profile production
                  set puldir $local_pwd/infrastructure
              case local
                  set -e GOOGLE_APPLICATION_CREDENTIALS
                  set -gx PYTEST_PULUMI_STACK local
                  set -gx SQL_PASSWORD "p@ssw0rd1"
                  set -gx SQL_USERNAME root
                  set -gx SQL_PORT 3306
                  return 0
              case '*'
                  echo not a known stack $stack
                  return 1
          end
          set -gx AWS_PROFILE $aws_profile
          pulumi -C $puldir stack select $stack
          if ! string match -qer "(bootstrap|monitoring).*" "$stack"
              set -gx GOOGLE_APPLICATION_CREDENTIALS $local_pwd/.local/spatial360-$gcp_config.json
              set -gx COPERNIC360_HOST (pulumi stack output -C $local_pwd/infrastructure engine-url)
          end
          gcloud config configurations activate copernic360-$gcp_config
      end
    '';
  };
  # }}}
}
