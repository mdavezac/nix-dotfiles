rec {
  description = "Astro-informatics dev";
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacevim-nix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = {
    self,
    flake-utils,
    devshell,
    nixpkgs,
    spacevim-nix,
    mach-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlays.default];
      };
      spacenix = {
        layers.git.github = true;
        layers.debugger.enable = true;
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
        languages.python = true;
        dash.python = ["pandas" "numpy"];
        treesitter-languages = ["json" "toml" "yaml" "bash" "fish"];
        colorscheme = "carbonight";
        cursorline = true;
        post.vim = ''
          autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
        '';
        telescope-theme = "ivy";
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        inherit spacenix;
        imports = [
          spacevim-nix.modules.${system}.prepackaged
          spacevim-nix.modules.devshell
        ];
        commands = [
          {package = pkgs.cmake;}
          {package = pkgs.doxygen;}
          {package = pkgs.black;}
          {package = pkgs.python38;}
        ];
      };
    });
}
