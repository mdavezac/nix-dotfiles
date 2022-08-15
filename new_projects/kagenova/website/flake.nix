rec {
  description = "Kagenova Website development environment";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = { self, flake-utils, devshell, nixpkgs, spacenix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        configuration.nvim = {
          layers.git.github = false;
          languages.markdown = true;
          languages.nix = true;
          languages.python = true;
          treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" "css" "html" ];
          colorscheme = "zenbones";
          post.vim = ''
            autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          '';
          formatters.isort.exe = pkgs.lib.mkForce "isort";
          formatters.black.exe = pkgs.lib.mkForce "black";
          layers.terminal.repl.favored.python = pkgs.lib.mkForce "require('iron.fts.python').ipython";
        };
      in
      {
        devShells.default =
          let
            nvim_pkg = spacenix.lib."${system}".spacenix-wrapper configuration;
            nvim_mod = spacenix.modules."${system}".devshell nvim_pkg;
          in
          pkgs.devshell.mkShell {
            imports = [ nvim_mod ];
            commands = [
              { package = pkgs.python38; }
              { package = pkgs.google-cloud-sdk; }
              { package = pkgs.pre-commit; }
              { package = pkgs.ruby_2_7; }
              { package = pkgs.inkscape; }
            ];
            devshell.name = description;
          };
      });
}
