{
  description = "SpaceNix environment";
  inputs = {
    devshell.url = "github:numtide/devshell";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = inputs@{ self, devshell, nixpkgs, ... }:
    let
      system = "x86_64-darwin";

      pkgs = import nixpkgs rec {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
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
      devShell.${system} =
        let
            nvim_pkg = inputs.spacenix.lib."${system}".spacenix-wrapper configuration;
            nvim_mod = inputs.spacenix.modules."${system}".devshell nvim_pkg;
        in
        pkgs.devshell.mkShell {
          devshell.name = "Spacenix";
          devshell.motd = "";
          imports = [ nvim_mod ];
        };
    };
}
