{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    spacevim-nix.url = "/Users/mdavezac/personal/spacenix/lazy";
  };

  outputs = {
    self,
    nixpkgs,
    devshell,
    flake-utils,
    spacevim-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlays.default];
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        devshell.packages = [spacevim-nix.apps.${system}.default];
        env = [
          {
            name = "LAZY_NIX_ROOT";
            eval = "$PWD/.local/lazynix/";
          }
        ];
        motd = "";
      };
    });
}
