{
  description = "Tripping Avenger's environment";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-21.05-darwin";

  inputs.devshell.url = "github:numtide/devshell";

  outputs = inputs@{ self, devshell, nixpkgs, ... }:
    let
      stable = inputs.nixpkgs-stable.legacyPackages.x86_64-darwin;
      pkgs = import nixpkgs {
        system = "x86_64-darwin";

        overlays = [
          devshell.overlay
          (self: super: {
            python38 = stable.python38;
            poetry = stable.poetry;
            mypy = stable.mypy;
            black = stable.black;
            flake8 = stable.flake8;
            postgresql = stable.postgresql;
          })
        ];
      };
    in {
      devShell.x86_64-darwin = pkgs.devshell.mkShell {
        imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
      };
    };
}
