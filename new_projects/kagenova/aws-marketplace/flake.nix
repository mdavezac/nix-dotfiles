rec {
  description = "360Learning environment";
  inputs = rec {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";

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
          languages.nix = true;
          languages.python = true;
          treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" ];
          colorscheme = "zenbones";
          post.vim = ''
            autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          '';
          dash.python = [ "tensorflow2" ];
          formatters.isort.exe = pkgs.lib.mkForce "isort";
          formatters.black.exe = pkgs.lib.mkForce "black";
          layers.terminal.repl.favored.python = pkgs.lib.mkForce "{ command = 'ipython' }";
        };
      in
      {
        devShells.default =
          let
            nvim_pkg = spacenix.lib."${system}".spacenix-wrapper configuration;
            nvim_mod = spacenix.modules."${system}".devshell nvim_pkg;
          in
          pkgs.devshell.mkShell { imports = [ nvim_mod ]; motd = ""; };
      });
}
