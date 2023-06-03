{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devshell.url = "github:numtide/devshell";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    spacevim-nix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = {
    self,
    nixpkgs,
    devshell,
    rust-overlay,
    flake-utils,
    spacevim-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay (import rust-overlay)];
      };
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
        layers.completion.sources."/" = [{name = "buffer";}];
        layers.completion.sources.":" = [{name = "cmdline";}];
        languages.markdown = true;
        languages.nix = true;
        languages.rust = true;
        treesitter-languages = ["json" "toml" "yaml" "bash" "fish" "latex"];
        colorscheme = "catppuccin-mocha";
        cursorline = true;
        telescope-theme = "ivy";
        formatters.nixpkgs-fmt.enable = false;
        formatters.alejandra.enable = true;
        formatters.rustfmt.args = pkgs.lib.mkForce ["--edition" "2021"];
        which-key. bindings = [
          {
            key = "<localleader>l";
            command = "<cmd>lua require('rust-tools').hover_actions.hover_actions()<cr>";
            description = "hover action";
          }
          {
            key = "<localleader>c";
            command = "<cmd>lua require('rust-tools').code_action_group.code_action_group()<cr>";
            description = "code action";
          }
        ];

        post.lua = ''
          require("rust-tools").setup({
            server = {
              cmd = {"rust-analyzer"};
              standalone=true;
            },
          })
        '';
      };
      rust-bin = pkgs.rust-bin.stable."1.63.0".default.override {
        extensions = ["rustfmt" "clippy" "rust-analysis"];
        targets = ["x86_64-apple-darwin" "wasm32-wasi" "x86_64-unknown-linux-musl"];
      };
      packages = [
        pkgs.darwin.apple_sdk.frameworks.Security
        pkgs.darwin.apple_sdk.frameworks.CoreFoundation
        pkgs.darwin.apple_sdk.frameworks.CoreServices
        pkgs.darwin.apple_sdk.frameworks.DiskArbitration
        pkgs.darwin.apple_sdk.frameworks.IOKit
        pkgs.darwin.apple_sdk.frameworks.Foundation
        rust-bin
        pkgs.rust-analyzer
        pkgs.binaryen
        pkgs.mandown
      ];
    in {
      devShells.default = pkgs.devshell.mkShell {
        inherit packages spacenix;
        imports = [spacevim-nix.modules.${system}.prepackaged spacevim-nix.modules.devshell];
        commands = [
          {
            command = "exec ssh hiro -L 8888:localhost:8888 -L 6006:localhost:6006 -t tmux new -As sparse";
            name = "hiro";
            help = "Connect to tmux on hiro";
          }
        ];
        motd = "";
      };
    });
}
