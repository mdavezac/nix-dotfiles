{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
in
{
  imports = (
    builtins.map mkProject [
      "plugin"
      "clearvr"
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
}
