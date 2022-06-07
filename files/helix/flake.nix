{
  description = "Helix environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.05";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, devshell, nixpkgs, ... }:
    let
      system = "x86_64-darwin";

      pkgs = import nixpkgs rec {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [ devshell.overlay ];
      };
    in
    {
      devShell.${system} =
        pkgs.devshell.mkShell {
          devshell.name = "Helix's dev environment";
          commands = [
            { package = "devshell.cli"; help = "Tensossht's developer environment"; }
            { package = "pre-commit"; }
          ];
          devshell.packages = [
          ];
        };
    };
}
