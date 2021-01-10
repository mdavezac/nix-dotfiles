{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.nix-index ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  imports = [ <home-manager/nix-darwin> ];
  users.users.mdavezac.home = "/Users/mdavezac";
  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.nerdfonts pkgs.victor-mono ];
  };

  programs.nix-index.enable = true;
  home-manager.users.mdavezac = import ./home.nix;

  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  system.defaults.trackpad.ActuationStrength = 0;
  system.defaults.trackpad.Clicking = true;

  services.skhd.enable = true;
  services.yabai.enable = true;
  services.yabai.package = pkgs.yabai;

  services.lorri.enable = true;
}
