{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devshell.url = "github:numtide/devshell";
    spacevim-nix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = {
    self,
    nixpkgs,
    devshell,
    spacevim-nix,
    flake-utils,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
      spacenix = {
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
        treesitter-languages = ["json" "toml" "yaml" "bash" "fish" "latex"];
        colorscheme = "materialbox";
        cursorline = true;
        telescope-theme = "ivy";
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        inherit spacenix;
        packages = [pkgs.tectonic pkgs.biber pkgs.pandoc];
        imports = [
          spacevim-nix.modules.${system}.prepackaged
          spacevim-nix.modules.devshell
        ];
        motd = "";
      };
    });
}
