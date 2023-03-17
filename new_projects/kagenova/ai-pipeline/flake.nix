{
  description = "SpaceNix environment";
  inputs = {
    devshell.url = "github:numtide/devshell";
    spacevim-nix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = inputs@{ self, devshell, nixpkgs, spacevim-nix, ... }:
    let
      system = "x86_64-darwin";

      pkgs = import nixpkgs rec {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [ devshell.overlay ];
      };

      spacenix = {
        layers.git.github = false;
        languages.nix = true;
        languages.python = true;
        treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" ];
        colorscheme = "zenbones";
        dash.python = [ "tensorflow2" ];
        formatters.isort.exe = "isort";
        formatters.black.exe = "black";
        layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
        layers.terminal.repl.repl-open-cmd = ''
          require('iron.view').split.vertical.botright(
            "50%", { number = false, relativenumber = false }
          )
        '';
      };
    in
    {
      devShell.${system} =
        pkgs.devshell.mkShell {
          devshell.motd = "";
          inherit spacenix;
          imports = [ spacevim-nix.modules.${system}.prepackaged spacevim-nix.modules.devshell ];
        };
    };
}
