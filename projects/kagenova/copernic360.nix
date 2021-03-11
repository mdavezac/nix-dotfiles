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
    };
  };
in
{
  imports = (
    builtins.map mkProject [
      "copernic360"
    ]
  );

  home.file.".aws/credentials".text = lib.generators.toINI {} aws;

  projects.kagenova.copernic360 =
    let
      starship = toTOML "starship.toml" starsets;
    in
      {
        enable = true;
        repos.copernic360 = {
          url =
            "https://gitlab.com/kagenova/kagemove/development/kagemove-webapi.git";
          dest = ".";
          settings.user.email = emails.gitlab;
          ignore = "copernic360.code-workspace";
        };
        extraEnvrc = ''
          eval "$(lorri direnv)"
          layout poetry 3.7
          check_precommit
          export STARSHIP_CONFIG=${starship}
          export AWS_REGION=eu-west-2
          export PULUMI_HOME=$(pwd)/.local/pulumi;
          [ -e TODOs.org ] || ln -s ~/org/copernic360.org TODOs.org
        '';
        file."copernic360.code-workspace".text = builtins.toJSON {
          folders = [
            { path = "."; }
            { path = "../ai-pipeline"; }
          ];
        };
      };
  home.file.".config/gcloud/configurations/config_copernic360-development".text = lib.generators.toINI {} {
    core = {
      account = "mayeul.davezac@kagenova.com";
      project = "spatial360-development";
    };
  };
  home.file.".config/gcloud/configurations/config_copernic360-staging".text = lib.generators.toINI {} {
    core = {
      account = "mayeul.davezac@kagenova.com";
      project = "spatial360-staging";
    };
  };
  home.file.".config/gcloud/configurations/config_copernic360-production".text = lib.generators.toINI {} {
    core = {
      account = "mayeul.davezac@kagenova.com";
      project = "spatial360-production";
    };
  };
}
