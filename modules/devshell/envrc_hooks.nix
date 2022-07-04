{ config, lib, pkgs, ... }:
let
  envrc_lines = workspaces: lib.mapAttrs
    (name: cfg: {
      envrc = [
        ''
          export PRJ_DATA_DIR=$(pwd)/.local/data
          export PRJ_ROOT=$PWD/.local/devshell
          source_env .local/devshell/
        ''
      ];
    })
    (lib.filterAttrs (k: v: v.enable && v.devshell.enable) workspaces);

  devshell_setup = workspaces: lib.mapAttrs
    (name: cfg: {
      file.".local/devshell/.envrc".source = ../files/flake_envrc;
    })
    (lib.filterAttrs (k: v: v.enable && v.devshell.enable) workspaces);
in
{
  config._workspaces = lib.mkMerge [
    (devshell_setup config.workspaces)
    (lib.mkOrder 10000 (envrc_lines config.workspaces))
  ];
}
