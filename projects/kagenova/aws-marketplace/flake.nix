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
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        imports = [
          spacenix.modules.${system}.prepackaged
          spacenix.modules.devshell
        ];
        spacenix = {
          layers.git.github = false;
          languages.markdown = true;
          languages.nix = true;
          languages.python = true;
          treesitter-languages = ["json" "toml" "yaml" "bash" "fish"];
          colorscheme = "zenbones";
          post.vim = ''
            autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          '';
          dash.python = ["tensorflow2"];
          formatters.isort.exe = "isort";
          formatters.black.exe = "black";
          formatters.nixpkgs-fmt.enable = false;
          formatters.alejandra.enable = true;
          layers.terminal.repl.repl-open-cmd = ''
            require('iron.view').split.vertical.botright(
                "40%", { number = false, relativenumber = false }
            )
          '';
          layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
          which-key.bindings = [
            {
              key = "<leader>tb";
              command = "<CMD>if &background == 'light' | set background=dark | else | set background=light | end <CR>";
              description = "Background";
            }
          ];
        };
      };
    });
}
