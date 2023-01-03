rec {
  description = "360Learning environment";
  inputs = rec {
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
    mach-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        imports = [
          (import "${devshell}/extra/language/c.nix")
          spacenix.modules.${system}.prepackaged
          spacenix.modules.devshell
        ];
        spacenix = {
          layers.git.github = true;
          layers.debugger.enable = true;
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
          languages.python = true;
          dash.python = ["pandas" "numpy"];
          treesitter-languages = ["json" "toml" "yaml" "bash" "fish"];
          colorscheme = "carbonight";
          cursorline = true;
          post.vim = ''
            autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          '';
          telescope-theme = "ivy";
          formatters.isort.exe = "isort";
          formatters.black.exe = "black";
          formatters.nixpkgs-fmt.enable = false;
          formatters.alejandra.enable = true;
          layers.terminal.repl.repl-open-cmd = ''
            require('iron.view').split.vertical.botright(
                "50%", { number = false, relativenumber = false }
            )
          '';
          layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
        };
        env = [
          {
            name = "LDFLAGS";
            eval = "-L$DEVSHELL_DIR/lib";
          }
          {
            name = "DYLD_FALLBACK_LIBRARY_PATH";
            prefix = "$DEVSHELL_DIR/lib";
          }
        ];
        commands = [
          {package = pkgs.cmake;}
          {package = pkgs.ninja;}
          {package = pkgs.curl;}
          {package = pkgs.doxygen;}
          {package = pkgs.black;}
          {package = pkgs.python38;}
        ];
      };
    });
}
