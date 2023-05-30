{
  pkgs,
  lib,
  options,
  config,
  ...
}: {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings.trusted-users = ["@admin"];
    configureBuildUsers = true;
  };

  services = {
    nix-daemon.enable = true;
    lorri.enable = false;
  };

  # Make fingerprint sudo work in terminal and in tmux
  system.activationScripts.postUserActivation.text = ''
    if ! command grep 'pam_tid.so' /etc/pam.d/sudo --silent; then
      command sudo sed -i -e '1s;^;auth       sufficient     pam_tid.so\n;' /etc/pam.d/sudo
    fi
    if ! command grep 'pam_reattach.so' /etc/pam.d/sudo --silent; then
      command sudo sed -i -e '1s;^;auth     optional     pam_reattach.so\n;' /etc/pam.d/sudo
    fi
  '';
  system.stateVersion = 4;
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "left";
      showhidden = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
    };
    NSGlobalDomain._HIHideMenuBar = true;
    trackpad.ActuationStrength = 0;
    trackpad.Clicking = true;
  };

  fonts = {
    fontDir.enable = false;
    fonts = [pkgs.nerdfonts];
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
    extraConfig = ''
      tap "fabianishere/personal", "https://github.com/fabianishere/homebrew-personal"
    '';
    brews = ["pam_reattach" "juliaup"];
    casks = [
      "remarkable"
      "kitty"
      "visual-studio-code"
      "brave-browser"
      "dash"
      "docker"
      "disk-inventory-x"
      "virtualbox"
      "nvidia-geforce-now"
      "keepingyouawake"
      "epic-games"
      "slack"
    ];
  };
}
