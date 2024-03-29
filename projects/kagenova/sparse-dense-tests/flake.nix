{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
    spacenix.url = "github:mdavezac/spacevim.nix"; # /Users/mdavezac/personal/spacenix";
  };

  outputs =
    { self
    , nixpkgs
    , devenv
    , spacenix
    , ...
    } @ inputs:
    let
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f:
        builtins.listToAttrs (map
          (name: {
            inherit name;
            value = f name;
          })
          systems);

      env = pkgs: {
        spacenix = {
          layers.neorg.enable = false;
          layers.completion.sources.other = [
            {
              name = "buffer";
              group_index = 3;
              priority = 100;
            }
            {
              name = "path";
              group_index = 2;
              priority = 50;
            }
            {
              name = "emoji";
              group_index = 2;
              priority = 50;
            }
          ];
          layers.completion.sources."/" = [{ name = "buffer"; }];
          layers.completion.sources.":" = [{ name = "cmdline"; }];
          languages.markdown = true;
          languages.nix = true;
          languages.python = true;
          colorscheme = "catppuccin-mocha";
          cursorline = true;
          telescope-theme = "ivy";
          formatters.nixpkgs-fmt.enable = false;
          formatters.alejandra.enable = true;
        };
      };
    in
    {
      devShells =
        forAllSystems
          (system:
            let
              pkgs = import nixpkgs { inherit system; };
            in
            {
              default = devenv.lib.mkShell {
                inherit inputs pkgs;
                modules = [
                  spacenix.modules.${system}.prepackaged
                  (env pkgs)
                ];
              };
            });
    };
}
