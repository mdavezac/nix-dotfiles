{
  config,
  lib,
  ...
}: {
  imports = [./modules/projects.nix ./projects];

  config.workspaces.helix = {
    enable = true;
    root = "personal";
    repos = [
      {
        url = "github:helix-editor/helix";
        settings.user.email = "2745737+mdavezac@users.noreply.github.com";
        exclude = ["/.envrc" "/.local"];
      }
    ];
    file.".local/helix/flake.nix".source = ./files/helix/flake.nix;
  };
}
