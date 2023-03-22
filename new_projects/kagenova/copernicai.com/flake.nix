rec {
  description = "Kagenova Website development environment";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacevim.url = "/Users/mdavezac/personal/spacenix";
    just-vim.url = "github:NoahTheDuke/vim-just";
    just-vim.flake = false;
  };

  outputs = {
    self,
    flake-utils,
    devshell,
    nixpkgs,
    spacevim,
    just-vim,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
      spacenix = {
        plugins.start = [
          (pkgs.vimUtils.buildVimPluginFrom2Nix
            {
              pname = "just-vim";
              version = just-vim.shortRev;
              src = just-vim;
            })
        ];
        layers.git.github = false;
        languages.markdown = true;
        languages.nix = true;
        languages.python = true;
        treesitter-languages = ["json" "toml" "yaml" "bash" "fish" "css" "html" "dockerfile"];
        colorscheme = "bluloco";
        layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
        layers.terminal.repl.repl-open-cmd = ''
          require('iron.view').split.vertical.botright(
              "40%", { number = false, relativenumber = false }
          )
        '';
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        inherit spacenix;
        motd = "";
        imports = [
          spacevim.modules.${system}.prepackaged
          spacevim.modules.devshell
        ];
        devshell.name = description;
      };
    });
}
