{ config, lib, pkgs, ... }:
let
  mkProject = import ../lib/project.nix "kagenova";
  emails = import ../lib/emails.nix;
in
{
  imports = builtins.map mkProject [ "twisto" ];

  projects.kagenova.twisto = {
    enable = true;
    repos.tripping-avenger = {
      url = "https://github.com/TwistoPayments/tripping-avenger.git";
      dest = ".";
      settings.user.email = emails.github;
      ignore = ''
        .vim/
        .local/
        .envrc
        .vscode/
        flake.nix
        flake.local
        .direnv
        devshell.toml
      '';
    };
    extraEnvrc = ''
      use flake
      layout poetry
    '';
    file."flake.nix".text = ''
      {
        description = "Tripping Avenger's environment";
        inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        inputs.nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-21.05-darwin";
      
        inputs.devshell.url = "github:numtide/devshell";
      
        outputs = inputs@{ self, devshell, nixpkgs, ... }:
          let
            stable = inputs.nixpkgs-stable.legacyPackages.x86_64-darwin;
            pkgs = import nixpkgs {
              system = "x86_64-darwin";
      
              overlays = [
                devshell.overlay
                (self: super: {
                  python38 = stable.python38;
                  poetry = stable.poetry;
                  mypy = stable.mypy;
                  black = stable.black;
                  flake8 = stable.flake8;
                  postgresql = stable.postgresql;
                })
              ];
            };
          in {
            devShell.x86_64-darwin = pkgs.devshell.mkShell {
              imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
            };
          };
      }
    '';
    file."devshell.toml".text = ''
      # https://numtide.github.io/devshell
      [[commands]]
      package = "devshell.cli"
      help = "Per project developer environments"
      
      [[commands]]
      package = "poetry"
      
      [[commands]]
      package = "python38"
      
      [[commands]]
      package = "postgresql"
      
      [devshell]
      packages = ["graphviz"]
    '';
  };
}
