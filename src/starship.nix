{ config, pkgs, lib, ... }: {
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      nix_shell = {
        disabled = false;
        format = ''[nix]($style) '';
      };
      conda.disabled = true;
      python = {
        disabled = true;
        format = ''via [$symbol$version]($style) '';
      };
      gcloud.disabled = true;
      aws.disabled = true;
      character = {
        success_symbol = "[➜](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
    };
  };
}
