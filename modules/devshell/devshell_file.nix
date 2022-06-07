{ config, lib, pkgs, ... }:
let
  devshell_file =
    { project ? ""
    , inputs ? ""
    , nixpkgs_url ? "github:nixos/nixpkgs/nixpkgs-21.11-darwin"
    , overlays ? [ ]
    , imports ? [ ]
    , packages ? [ ]
    }: {
      text = ''
        {
          description = "${project}";
          inputs = rec {
            nixpkgs.url = "${nixpkgs_url}";

            flake-utils.url = "github:numtide/flake-utils";
            devshell.url = "github:numtide/devshell";
            ${builtins.concatStringsSep "\n    " inputs}
          };

          outputs = { self, flake-utils, devshell, nixpkgs }:
            flake-utils.lib.eachDefaultSystem (system:
              let
                pkgs = import nixpkgs {
                  inherit system;
                  overlays = [
                    devshell.overlay
                    ${builtins.concatStringsSep "\n    " overlays}
                  ];
                };
              in
              {
                devShell = pkgs.devshell.mkShell {
                  name = "${project}";
                  imports = [
                      ${builtins.concatStringsSep "\n    " imports}
                  ];
                  devshell.packages = [
                    ${packages}
                  ];
                };
              });
        }
      '';
    };

  devshell_setup = wname: wcfg: devshell_file {
    inherit (wcfg.devshell) inputs imports overlays nixpkgs_url;
    project = wname;
    packages = builtins.concatStringsSep "\n" (
      builtins.map (v: "pkgs." + v) wcfg.devshell.packages
    );
  };
  add_workspace_files = key_func: file_func: lib.mapAttrs'
    (wname: wcfg: lib.nameValuePair (key_func wname wcfg) (file_func wname wcfg))
    (active_workspaces config._workspaces);
  active_workspaces = cfg: lib.filterAttrs (k: v: v.enable && v.devshell.enable) cfg;
  root_path = name: cfg: cfg.root + "/" + name + "/";
  root_file_path = filepath: workspace_name: cfg:
    (root_path workspace_name cfg) + filepath;
in
{
  config.home.file = (add_workspace_files
    (root_file_path ".local/devshell/flake.nix")
    devshell_setup
  );
}
