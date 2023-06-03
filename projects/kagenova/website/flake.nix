rec {
  description = "Kagenova Website development environment";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacevim.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = {
    self,
    flake-utils,
    devshell,
    nixpkgs,
    spacevim,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
      spacenix = {
        layers.git.github = false;
        languages.markdown = true;
        languages.nix = true;
        languages.python = true;
        treesitter-languages = ["json" "toml" "yaml" "bash" "fish" "css" "html" "dockerfile"];
        colorscheme = "zenbones";
        formatters.isort.exe = "isort";
        formatters.black.exe = "black";
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        inherit spacenix;
        imports = [
          spacevim.modules.${system}.prepackaged
          spacevim.modules.devshell
        ];
        devshell.name = description;
      };
    });
}
