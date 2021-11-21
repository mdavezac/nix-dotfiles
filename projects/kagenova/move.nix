{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
  utils = (pkgs.callPackage (import ../lib/utils.nix) {});
in
{
  imports = (
    builtins.map mkProject [
      "plugin"
      "clearvr"
      "mobile"
      "meshing"
    ]
  );

  # clearvr: {{{
  projects.kagenova.clearvr = {
    enable = true;
    repos.clearvr = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-clearvr-pilot.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = '''';
    };
    file.".git/info/exclude".text = ''
      .vim/
      .local/
      .envrc
      .vscode/
      clearvr.code-workspace
    '';
    extraEnvrc = ''
      check_precommit
      export PRJ_DATA_DIR=$(pwd)/.local/devshell/data
      export PRJ_ROOT=$PWD/.local/devshell
    '';
    file."clearvr.code-workspace".source = utils.toPrettyJSON {
      folders = [
        { path = "."; }
        { path = "../plugin"; }
        { path = "../mobile"; }
      ];
      settings = {
        "python.venvPath" = "\${workspaceFolder}/.local/venvs";
      };
    };
  };
  # }}}

  # plugin: {{{
  projects.kagenova.plugin = {
    enable = true;
    repos.plugin = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-plugin.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .local/
        .envrc
      '';
    };
    extraEnvrc = ''
      check_precommit
    '';
  };
  # }}}
  # mobile: {{{
  projects.kagenova.mobile = {
    enable = true;
    repos.plugin = {
      url =
        "https://gitlab.com/kagenova/kagemove/development/kagemove-demo-mobile.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = ''
        .vim/
        .local/
        .envrc
      '';
    };
  };
  # }}}
  # meshing: {{{
  projects.kagenova.meshing = {
    enable = true;
    repos.meshing = {
      url = "https://gitlab.com/kagenova/hacks/kagemove-clearvr-mesh-merge.git";
      dest = ".";
      settings.user.email = emails.gitlab;
      ignore = '''';
    };
    file.".git/info/exclude".text = ''
      .vim/
      .local/
      .envrc
      .vscode/
    '';
    extraEnvrc = ''
      check_precommit
      export PRJ_DATA_DIR=$(pwd)/.local/devshell/data
      export PRJ_ROOT=$PWD/.local/devshell
      source_env .devshell
    '';
  };
  # }}}
}
