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
          layers.git.github = false;
          languages.markdown = true;
          languages.nix = true;
          languages.python = true;
          layers.neorg.enable = false;
          treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" ];
          colorscheme = "zenbones";
          dash.python = [ "tensorflow2" ];
          formatters.isort.exe = pkgs.lib.mkForce "isort";
          formatters.black.exe = pkgs.lib.mkForce "black";
          formatters.nixpkgs-fmt.enable = false;
          formatters.alejandra.enable = true;
          layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
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
          telescope-theme = "ivy";
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
