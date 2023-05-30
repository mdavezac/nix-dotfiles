{
  description = "My dotfiles";
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

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

    spacenix.url = "github:mdavezac/spacevim.nix";

    nuscripts.url = "github:nushell/nu_scripts";
    nuscripts.flake = false;
  };
  outputs = inputs @ {
    self,
    nixpkgs-stable,
    darwin,
    home-manager,
    flake-utils,
    spacenix,
    ...
  }: let
    system = "x86_64-darwin";
    nixpkgsConfig = with inputs; {
      config = {allowUnfree = true;};
      overlays = [
        (final: prev: let
          system = prev.stdenv.system;
        in rec {
          foreign-fish = inputs.foreign-fish;
          nord-kitty = inputs.nord-kitty;
          kitty-themes = inputs.kitty-themes;
          nuscripts = inputs.nuscripts;
        })
      ];
    };
  in {
    darwinConfigurations = {
      macbook = darwin.lib.darwinSystem {
        system = system;
        inputs = inputs;
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin.nix
          {
            nix.nixPath = {nixpkgs = "$HOME/.config/nixpkgs/nixpkgs.nix";};
            nixpkgs = nixpkgsConfig;
            users.users.mdavezac.home = "/Users/mdavezac";
            home-manager.useGlobalPkgs = true;
            home-manager.users.mdavezac = {imports = [./home.nix];};
            nix.registry = {
              self.flake = inputs.self;
              nixpkgs = {
                from = {
                  id = "nixpkgs";
                  type = "indirect";
                };
                to = {
                  owner = "NixOS";
                  repo = "nixpkgs-22.11-darwin";
                  rev = inputs.nixpkgs-stable.rev; # (3)
                  type = "github";
                };
              };
              nixpkgs-unstable = {
                from = {
                  id = "nixpkgs-unstable";
                  type = "indirect";
                };
                to = {
                  owner = "NixOS";
                  repo = "nixpkgs-unstable";
                  rev = inputs.nixpkgs-unstable.rev; # (3)
                  type = "github";
                };
              };
            };
          }
        ];
      };
    };
    devShell.x86_64-darwin = let
      pkgs = import inputs.nixpkgs-stable {
        system = system;
        config = {allowUnfree = true;};
        overlays = [
          inputs.devshell.overlays.default
        ];
      };
    in
      pkgs.devshell.mkShell {
        name = "dotfiles";
        packages = [pkgs.pre-commit];

        commands = [
          {
            name = "build";
            command = "darwin-rebuild build --flake .#macbook";
            help = "Build the current configuration";
          }
          {
            name = "dotsync";
            command = "darwin-rebuild switch --flake .#macbook";
            help = "Switch to the current configuration";
          }
        ];
      };
  };
}
