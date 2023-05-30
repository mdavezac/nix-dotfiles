{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.carapace];
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
    extraConfig = ''
      source ${pkgs.nuscripts}/custom-completions/git/git-completions.nu
      source ${pkgs.nuscripts}/custom-completions/nix/nix-completions.nu
      source ${pkgs.nuscripts}/custom-completions/poetry/poetry-completions.nu
    '';
  };
  programs.starship = {
    enableNushellIntegration = true;
  };
  programs.direnv = {
    enableNushellIntegration = true;
  };
  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      filter_mode = "directory";
    };
    enableFishIntegration = false;
    enableNushellIntegration = true;
  };
}
