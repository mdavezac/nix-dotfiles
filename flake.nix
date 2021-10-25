{
  description = "My dotfiles";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";

    foreign-fish = {
      url = "github:oh-my-fish/plugin-foreign-env";
      flake = false;
    };
    nord-kitty = {
      url = "github:connorholyday/nord-kitty";
      flake = false;
    };
    kitty-themes = {
      url = "github:dexpota/kitty-themes";
      flake = false;
    };
    rnix-lsp.url = github:nix-community/rnix-lsp;
  };
  outputs = inputs@{ self, nixpkgs, darwin, home-manager, flake-utils, ... }:
    let
      nixpkgsConfig = with inputs; {
        config = { allowUnfree = true; };
        overlays = [
          (final: prev:
            let system = prev.stdenv.system;
            in
            rec {
              stable = nixpkgs-stable-darwin.legacyPackages.${system};
              kitty = stable.kitty;
              foreign-fish = inputs.foreign-fish;
              nord-kitty = inputs.nord-kitty;
              kitty-themes = inputs.kitty-themes;
            })
        ];
      };
    in
    {
      darwinConfigurations = {
        macbook = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          inputs = inputs;
          modules = [
            home-manager.darwinModules.home-manager
            ./darwin.nix
            rec {
              nix.nixPath = { nixpkgs = "$HOME/.config/nixpkgs/nixpkgs.nix"; };
              nixpkgs = nixpkgsConfig;
              users.users.mdavezac.home = "/Users/mdavezac";
              home-manager.useGlobalPkgs = true;
              home-manager.users.mdavezac = { imports = [ ./home.nix ]; };
            }
          ];
        };
      };
      devShell.x86_64-darwin =
        let
          pkgs = import nixpkgs {
            system = "x86_64-darwin";
            config = { allowUnfree = true; };
            overlays = [
              inputs.devshell.overlay
              (final: prev: {
                rnix-lsp = inputs.rnix-lsp.defaultPackage.x86_64-darwin;
              })
            ];
          };
        in
        pkgs.devshell.mkShell {
          name = "dotfiles";
          packages = [ pkgs.devshell.cli pkgs.rnix-lsp ];

          commands = [
            {
              name = "build";
              command = "darwin-rebuild build --flake .#macbook";
              help = "Build the current configuration";
            }
            {
              name = "update";
              command = "darwin-rebuild switch --flake .#macbook";
              help = "Switch to the current configuration";
            }
          ];
        };
    };
}
