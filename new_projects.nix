{ config, lib, ... }: {
  imports = [ ./modules/projects.nix ];

  config.workspaces."aws-marketplace" = {
    enable = true;
    root = "new_projects";
    repos = [
      {
        url = "github:mdavezac/spglib.jl";
        settings.user.email = "2745737+mdavezac@users.noreply.github.com";
        exclude = [ "/.envrc" "/.local" ];
      }
    ];
    python.enable = true;
    python.version = "3.10";
    python.packager = "poetry";
    devshell.enable = true;
    /* devshell.nixpkgs_url = "github:nixos/nixpkgs/nixpkgs-unstable"; */
  };

  config.workspaces.helix = {
    enable = true;
    root = "personal";
    repos = [
      {
        url = "github:helix-editor/helix";
        settings.user.email = "2745737+mdavezac@users.noreply.github.com";
        exclude = [ "/.envrc" "/.local" ];
      }
    ];
    file.".local/helix/flake.nix".source = ./files/helix/flake.nix;
  };
}
