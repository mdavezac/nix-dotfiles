{ config, pkgs, lib, ... }: {
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  home.packages = [
    pkgs.cacert
    pkgs.any-nix-shell
    pkgs.neofetch
    pkgs.curl
  ];

  programs.home-manager.enable = true;

  imports = [
    ./src/spacevim
    ./src/ssh.nix
    ./src/fish.nix
    ./src/cmdl.nix
    ./src/git.nix
    ./src/tmux.nix
    ./src/starship.nix
    ./src/kitty.nix
    ./src/vscode
    ./projects
  ];
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.JULIA_PROJECT = "@.";
  home.file.".skhdrc".text = (builtins.readFile (pkgs.substituteAll {
    src = ./files/skhdrc;
    kitty = "${pkgs.kitty}";
  }));
  home.file.".yabairc".source = ./files/yabairc;
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
}
