{ config, pkgs, lib, ... }: {
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      nix_shell = {
        disabled = false;
        format = ''[nix]($style) '';
      };
      conda.disabled = false;
      python = {
        enabled = true;
        format = ''via [$symbol$version]($style) '';
      };
      gcloud.disabled = true;
      character = {
        symbol = "➜";
        error_symbol = "✗";
        use_symbol_for_status = true;
      };
    };
  };
}
