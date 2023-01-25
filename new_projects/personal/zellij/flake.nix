{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
    rust-overlay.url = "github:oxalica/rust-overlay";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    spacenix,
    rust-overlay,
    ...
  } @ inputs: let
    systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = f:
      builtins.listToAttrs (map
        (name: {
          inherit name;
          value = f name;
        })
        systems);

    env = pkgs: let
      rust-bin = pkgs.rust-bin.stable."1.63.0".default.override {
        extensions = ["rustfmt" "clippy" "rust-analysis"];
        targets = ["x86_64-apple-darwin" "wasm32-wasi" "x86_64-unknown-linux-musl"];
      };
    in {
      packages = [
        pkgs.darwin.apple_sdk.frameworks.Security
        pkgs.darwin.apple_sdk.frameworks.CoreFoundation
        pkgs.darwin.apple_sdk.frameworks.CoreServices
        pkgs.darwin.apple_sdk.frameworks.DiskArbitration
        pkgs.darwin.apple_sdk.frameworks.IOKit
        pkgs.darwin.apple_sdk.frameworks.Foundation
        pkgs.rustup
        pkgs.binaryen
        pkgs.mandown
      ];

      languages.rust.enable = false;
      languages.rust.packages.rustc = rust-bin;
      languages.rust.packages.cargo = rust-bin;
      env.GIT_EDITOR = "vi";
      scripts.vi.exec = ''
        [ -n "$NVIM" ] && nvim --server $NVIM --remote $@ || exec nvim $@
      '';
      scripts.vim.exec = ''
        [ -n "$NVIM" ] && nvim --server $NVIM --remote $@ || exec nvim $@
      '';

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
      };
    };
  in {
    devShells =
      forAllSystems
      (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [(import rust-overlay)];
        };
      in {
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
