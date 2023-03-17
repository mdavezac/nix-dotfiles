{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    spacevim-nix.url = "/Users/mdavezac/personal/spacenix";
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
      spacenix = {
        layers.neorg.enable = false;
        layers.completion.sources.other = [
          {
            name = "buffer";
            group_index = 3;
            priority = 100;
          }
          {
            name = "path";
            group_index = 2;
            priority = 50;
          }
          {
            name = "emoji";
            group_index = 2;
            priority = 50;
          }
        ];
        layers.completion.sources."/" = [{name = "buffer";}];
        layers.completion.sources.":" = [{name = "cmdline";}];
        languages.markdown = true;
        languages.nix = true;
        languages.cpp = true;
        languages.cmake = true;
        languages.rust = false;
        colorscheme = "bluloco";
        cursorline = true;
        telescope-theme = "ivy";
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        inherit spacenix;
        imports = [spacevim-nix.modules.${system}.prepackaged spacevim-nix.modules.devshell];
        motd = "";
      };
    });
}
