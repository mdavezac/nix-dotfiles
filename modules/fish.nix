{ config, lib, pkgs, ... }:
let
  fish_setup = workspaces: lib.mapAttrs
    (name: cfg:
      let
        session_name = builtins.replaceStrings [ "-" " " ] [ "_" "_" ] name;
        root_name = if (builtins.isNull cfg.root) then "" else
        (
          (builtins.replaceStrings [ "/" ] [ "_" ] cfg.root) + "_"
        );
      in
      {
        envrc = [
          ''
            export fish_history=${root_name}${session_name}
          ''
        ];
      })
    (lib.filterAttrs (k: v: v.fish.enable) workspaces);
in
{
  config._workspaces = lib.mkMerge [
    (fish_setup config.workspaces)
  ];
}
