{
  description = "SpaceNix environment";
  inputs = {
    devshell.url = "github:numtide/devshell";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    spacenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, devshell, nixpkgs, ... }:
    let
      system = "x86_64-darwin";

      pkgs = import nixpkgs rec {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [ devshell.overlay ];
      };

      configuration.nvim = {
        layers.git.github = true;
        languages.nix = true;
        languages.python = false;
        layers.dash.enable = false;
        treesitter-languages = [ "json" "toml" "yaml" ];
        colorscheme = "papercolor";
        post.vim = ''
          autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
        '';
      };
    in
    {
      devShell.${system} =
        let
          nvim = inputs.spacenix.wrapper.${system} configuration;
          vicmd = ''
            rpc=$PRJ_DATA_DIR/nvim.rpc
            [ -e $rpc ] && ${pkgs.neovim-remote}/bin/nvr --servername $rpc -s $@ || ${nvim}/bin/nvim $@
          '';
          vi_args = [
            "${pkgs.neovim-remote}/bin/nvr"
            "--servername"
            "$PRJ_DATA_DIR/nvim.rpc"
            "-cc split"
            "--remote-wait"
            "-s"
            "$@"
          ];
        in
        pkgs.devshell.mkShell {
          devshell.name = "Spacenix";
          devshell.packages = [ nvim ];
          devshell.motd = "";
          commands = builtins.map (x: { name = x; command = vicmd; }) [ "vim" "vi" ];
          env = [
            { name = "EDITOR"; value = builtins.concatStringsSep " " vi_args; }
            { name = "NVIM_LISTEN_ADDRESS"; eval = "$PRJ_DATA_DIR/nvim.rpc"; }
          ];
        };
    };
}
