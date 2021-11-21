{
  description = "ClearVR integration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.05-darwin";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    spacenix.url = "/Users/mdavezac/personal/spacenix";

    omnisharp-vim = { url = "github:OmniSharp/omnisharp-vim"; flake = false; };
  };

  outputs = inputs@{ self, devshell, nixpkgs, ... }:
    let
      system = "x86_64-darwin";
      configuration.nvim = {
        languages.nix = true;
        layers.projects.enable = false;
        treesitter-languages = [ "json" "toml" "c_sharp" "yaml" ];
        colorscheme = "zenbones";
        plugins.start = [ pkgs.vimPlugins.vim-csharp pkgs.vimPlugins.omnisharp-vim ];
      };
      omnishapr-overlay =
        (self: super: {
          vimPlugins = super.vimPlugins // {
            omnisharp-vim = self.vimUtils.buildVimPluginFrom2Nix {
              pname = "omnisharp-vim";
              version = inputs.omnisharp-vim.shortRev;
              src = inputs.omnisharp-vim;
            };
          };
        });

      pkgs = import nixpkgs rec {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [ devshell.overlay omnishapr-overlay ];
      };
    in
    {
      devShell.${system} =
        let
          cmd = "${pkgs.neovim-remote}/bin/nvr --servername $PRJ_DATA_DIR/nvim.rpc -s $@";
          nvim = (inputs.spacenix.wrapper.${system} configuration);
        in
        pkgs.devshell.mkShell {
          devshell.packages = [ nvim pkgs.dotnetCorePackages.sdk_3_1 ];
          commands = builtins.map (x: { name = x; command = cmd; }) [ "vim" "vi" ];
        };
      apps.repl."${system}" = inputs.flake-utils.lib.mkApp {
        drv = pkgs.writeShellScriptBin "repl" ''
          confnix=$(mktemp)
          echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
          trap "rm $confnix" EXIT
          nix repl $confnix
        '';
      };
    };
}
