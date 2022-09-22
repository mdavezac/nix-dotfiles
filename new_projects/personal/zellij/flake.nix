rec {
  description = "Tensossht development environment";
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
          formatters.nixpkgs-fmt.enable = pkgs.lib.mkForce false;
          languages.python = false;
          languages.rust = true;
          treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" ];
          colorscheme = "zenbones";
          post.vim = ''
            autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          '';
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
