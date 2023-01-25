{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
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
        languages.python.enable = true;
        languages.python.package = pkgs.python38;
        packages = [ pkgs.poetry pkgs.pandoc ];
        env.GIT_EDITOR = "vi";
        scripts.vi.exec = ''
          [ -n "$NVIM" ] && nvim --server $NVIM --remote $@ || exec nvim $@
        '';
        scripts.vim.exec = ''
          [ -n "$NVIM" ] && nvim --server $NVIM --remote $@ || exec nvim $@
        '';
        spacenix = {
          languages.python = true;
          languages.nix = true;
          languages.markdown = true;
          colorscheme = "monochrome";
          layers.pimp.notify = false;
          layers.neorg.workspaces = [
            {
              name = "neorg";
              path = "~/neorg/";
              key = "n";
            }
          ];
          layers.neorg.gtd = "neorg";
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
          # languages.python = true;
          # languages.nix = true;
          # languages.markdown = true;
          # colorscheme = "oh-lucy";
          # layers.pimp.notify = true;
          # layers.git.github = false;
          # layers.neorg.enable = true;
          # layers.completion.sources.other = [
          #   {
          #     name = "buffer";
          #     group_index = 3;
          #     priority = 100;
          #   }
          #   {
          #     name = "path";
          #     group_index = 2;
          #     priority = 50;
          #   }
          #   {
          #     name = "emoji";
          #     group_index = 2;
          #     priority = 50;
          #   }
          # ];
          # layers.completion.sources."/" = [{name = "buffer";}];
          # layers.completion.sources.":" = [{name = "cmdline";}];

          # formatters.nixpkgs-fmt.enable = false;
          # formatters.alejandra.enable = true;
          # formatters.isort.exe = "isort";
          # formatters.black.exe = "black";

          # treesitter-languages = ["json" "toml" "yaml" "bash" "fish"];
          # dash.python = ["tensorflow2"];
          # layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
          #        layers.terminal.repl.repl-open-cmd = ''
          #          require('iron.view').split.vertical.botright(
          #            "50%", { number = false, relativenumber = false }
          #          )
          #        '';
          #        telescope-theme = "ivy";
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
