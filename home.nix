{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    pkgs.cacert
    pkgs.any-nix-shell
    pkgs.neofetch
    pkgs.curl
    pkgs.aws-vault
    pkgs.tealdeer
    pkgs.sd
    pkgs.lastpass-cli
    pkgs.cachix
    pkgs.du-dust
  ];

  programs.home-manager.enable = true;

  imports = [
    ./src/ssh.nix
    ./src/fish.nix
    ./src/nushell
    ./src/cmdl.nix
    ./src/git.nix
    ./src/tmux.nix
    ./src/starship.nix
    ./src/kitty.nix
    # ./src/wezterm.nix
    # ./src/zellij.nix
    # ./src/vscode
    # ./src/kakoune
    # ./src/doom
    ./projects.nix
  ];
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.JULIA_PROJECT = "@.";
  home.sessionVariables.DIRENV_LOG_FORMAT = "";
  home.file.".pdbrc.py".source = ./files/pdbrc.py;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "19.09";

  # home.activation.vscode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   cd $HOME/Applications
  #   $DRY_RUN_CMD sudo ln -fs ${vscode}/Applications/Visual\ Studio\ Code.app/ .
  # '';
}
