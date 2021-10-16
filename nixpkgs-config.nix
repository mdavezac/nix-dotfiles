{
  allowUnfree = true;
  allowUnsupportedSystem = true;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
