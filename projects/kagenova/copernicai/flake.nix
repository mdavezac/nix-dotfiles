{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
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
        layers.git.github = false;
        languages.markdown = true;
        languages.nix = true;
        languages.python = true;
        treesitter-languages = ["json" "toml" "yaml" "bash" "fish"];
        colorscheme = "Carbonfox";
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
        init.lua = ''
            require('nightfox').setup({
            options = {
              -- Compiled file's destination location
              dim_inactive = true,    -- Non focused panes set to alternative background
              styles = {               -- Style to be applied to different syntax groups
                comments = "italic",     -- Value is any valid attr-list value `:help attr-list`
                conditionals = "NONE",
                constants = "NONE",
                functions = "NONE",
                keywords = "bold",
                numbers = "NONE",
                operators = "NONE",
                strings = "italic",
                types = "NONE",
                variables = "NONE",
              },
            },
          })
        '';
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        packages = [pkgs.poetry pkgs.pandoc pkgs.python39];
        language.c.compiler = pkgs.gcc;
        imports = [
          # spacevim-nix.modules.${system}.prepackaged
          # spacevim-nix.modules.devshell
          "${devshell}/extra/language/c.nix"
        ];
        env = [
          {
            name = "OPENCV_IO_ENABLE_OPENEXR";
            value = 1;
          }
        ];
        motd = "";
      };
    });
}
