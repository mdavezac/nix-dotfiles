rec {
  description = "Kagenova Website development environment";
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
      spaceconfig = {
        layers.git.github = false;
        languages.markdown = true;
        languages.nix = true;
        languages.python = true;
        treesitter-languages = [
          "json"
          "toml"
          "yaml"
          "bash"
          "fish"
          "css"
          "html"
          "dockerfile"
        ];
        colorscheme = "zenbones";
        post.vim = ''
          autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
        '';
        formatters.isort.exe = pkgs.lib.mkForce "isort";
        formatters.black.exe = pkgs.lib.mkForce "black";
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        spacenix = spaceconfig;
        imports = [
          spacenix.modules.${system}.prepackaged
          spacenix.modules.devshell
        ];
        commands = [
          {package = pkgs.python37;}
          {package = pkgs.poetry;}
          {package = pkgs.google-cloud-sdk;}
          {package = pkgs.pre-commit;}
          {package = pkgs.ruby_2_7;}
          {package = pkgs.inkscape;}
        ];
        devshell.name = description;
      };
    });
}
