rec {
  description = "Tensossht development environment";
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = {
    self,
    flake-utils,
    devshell,
    nixpkgs,
    spacenix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
      spacevim = {
        layers.git.github = false;
        languages.markdown = true;
        languages.nix = true;
        languages.python = true;
        treesitter-languages = ["json" "toml" "yaml" "bash" "fish"];
        colorscheme = "zenbones";
        dash.python = ["tensorflow2"];
        formatters.isort.exe = "isort";
        formatters.black.exe = "black";
        formatters.nixpkgs-fmt.enable = false;
        formatters.alejandra.enable = true;
        layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
        layers.terminal.repl.repl-open-cmd = ''
          require('iron.view').split.vertical.botright(
            "50%", { number = false, relativenumber = false }
          )
        '';
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
        telescope-theme = "ivy";
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        imports = [spacenix.modules.${system}.prepackaged];
        motd = "";
        spacenix = spacevim;
        commands = [
          {
            name = "vi";
            command = ''[ -n "$NVIM" ] && nvim --server $NVIM --remote $@ || exec nvim $@'';
          }
          {
            name = "vim";
            command = ''[ -n "$NVIM" ] && nvim --server $NVIM --remote $@ || exec nvim $@'';
          }
        ];
      };
    });
}
