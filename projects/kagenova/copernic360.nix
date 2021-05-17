{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
  aws = (import ../../machine.nix).aws;
  toTOML = path: toml: pkgs.runCommand "init.toml"
    {
      buildInputs = [ pkgs.remarshal ];
      preferLocalBuild = true;
    } ''
    remarshal -if json -of toml \
      < ${pkgs.writeText "${path}" (builtins.toJSON toml)} \
      > $out
  '';
  original = import ../../src/starship.nix { inherit config lib pkgs; };
  starsets = original.programs.starship.settings // {
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

  home.file.".aws/credentials".text = lib.generators.toINI {} aws;

  projects.kagenova.copernic360 = {
    enable = true;
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
      export STARSHIP_CONFIG=${toTOML "starship.toml" starsets}
      [ -e TODOs.org ] || ln -s ~/org/copernic360.org TODOs.org
    '';
    file."copernic360.code-workspace".text = builtins.toJSON {
      folders = [
        { path = "."; }
        { path = "../ai-pipeline"; }
      ];
      settings = {
        "python.venvPath" = "\${workspaceFolder}/.local/venvs";
      };
    };
  };

  home.file.".config/gcloud/configurations/config_copernic360-development".text = lib.generators.toINI {} {
    core = {
      account = "pulumi-deployment@spatial360-development.iam.gserviceaccount.com";
      project = "spatial360-development";
    };
  };
  home.file.".config/gcloud/configurations/config_copernic360-staging".text = lib.generators.toINI {} {
    core = {
      account = "pulumi-deployment@spatial360-staging.iam.gserviceaccount.com";
      project = "spatial360-staging";
    };
  };
  home.file.".config/gcloud/configurations/config_copernic360-production".text = lib.generators.toINI {} {
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
      export STARSHIP_CONFIG=${toTOML "starship.toml" starsets}
      export PULUMI_HOME=$(pwd)/.local/pulumi;
      [ -e TODOs.org ] || ln -s ~/org/copernic360.org TODOs.org
    '';
    file."ai-pipeline.code-workspace".text = builtins.toJSON {
      folders = [
        { path = "."; }
      ];
      settings = {
        "python.venvPath" = "\${workspaceFolder}/.local/venvs";
        "workbench.colorTheme" = "Material Theme Darker High Contrast";
        "nixEnvSelector.nixFile" = "\${workspaceFolder}/shell.nix";
      };
    };
    file.".local/bin/switch_stack.fish".text = ''
      function switch_stack -a stack
          set local_pwd "/Users/mdavezac/kagenova/ai-pipeline/"
          switch $stack
              case development
                  set name development
                  set puldir $local_pwd/infrastructure
              case bootstrap
                  set name development
                  set puldir $local_pwd/bootstrap
              case staging
                  set name staging
                  set puldir $local_pwd/infrastructure
              case bootstrap-staging
                  set name staging
                  set puldir $local_pwd/bootstrap
              case bootstrap
                  set name production
                  set puldir $local_pwd/infrastructure
              case bootstrap-production
                  set name production
                  set puldir $local_pwd/bootstrap
              case production
                  set name production
                  set puldir $local_pwd/infrastructure
              case '*'
                  echo not a known stack $stack
                  return 1
          end
          if test -z (string match "bootstrap*" "$stack")
              set -gx GOOGLE_APPLICATION_CREDENTIALS $local_pwd/.local/spatial360-$name.json
              set -gx COPERNIC360_HOST (pulumi stack output -C $local_pwd/infrastructure engine-url)
          else
              set -e GOOGLE_APPLICATION_CREDENTIALS
              set -e COPERNIC360_HOST
          end
          set -gx AWS_PROFILE $name
          gcloud config configurations activate copernic360-$name
          pulumi -C $puldir stack select $stack
      end
    '';
  };
  # }}}
}
