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
    extraConfig = let
      atuin = pkgs.runCommand "atuin.nu" {} ''
        ${pkgs.atuin}/bin/atuin init nu --disable-up-arrow > $out
      '';
    in ''
      source ${pkgs.nuscripts}/custom-completions/git/git-completions.nu
      source ${pkgs.nuscripts}/custom-completions/nix/nix-completions.nu
      source ${pkgs.nuscripts}/custom-completions/poetry/poetry-completions.nu
      source ${atuin}
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
    settings = {
      filter_mode_shell_up_key_binding = "directory";
      filter_mode = "directory";
    };
    enableFishIntegration = false;
    enableNushellIntegration = false;
  };
}
