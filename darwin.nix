{ pkgs, lib, options, config, ... }: {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    trustedUsers = [ "@admin" ];
  };

  services = {
    nix-daemon.enable = true;
    lorri.enable = true;
  };

  # Copy applications into ~/Applications/Nix Apps. This workaround allows us
  # to find applications installed by nix through spotlight.
  system.activationScripts.applications.text = pkgs.lib.mkForce (
    ''
      if [[ -L "$HOME/Applications" ]]; then
        rm "$HOME/Applications"
        mkdir -p "$HOME/Applications/Nix Apps"
      fi
      rm -rf "$HOME/Applications/Nix Apps"
      mkdir -p "$HOME/Applications/Nix Apps"
      for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do
        src="$(/usr/bin/stat -f%Y "$app")"
        echo "copying $app"
        cp -rL "$src" "$HOME/Applications/Nix Apps"
      done
    ''
  );
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

  users.nix.configureBuildUsers = true;

  fonts = {
    enableFontDir = false;
    fonts = [ pkgs.nerdfonts ];
  };

  homebrew = {
    enable = true;
    cleanup = "zap";
    extraConfig = ''
      tap "fabianishere/personal", "https://github.com/fabianishere/homebrew-personal"
      tap "homebrew/cask", "https://github.com/Homebrew/homebrew-cask/"
    '';
    brews = [ "dust" "node" "pam_reattach" ];
    casks = [
      "kitty"
      "visual-studio-code"
      "brave-browser"
      "dash"
      "docker"
      "disk-inventory-x"
      "virtualbox"
      "virtualbox-extension-pack"
      "julia"
      "nvidia-geforce-now"
      "unity-hub"
      "keepingyouawake"
      "epic-games"
      "slack"
      "openvpn-connect"
    ];
  };
}
