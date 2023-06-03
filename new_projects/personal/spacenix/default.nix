{
  config,
  lib,
  pkgs,
  ...
}: {
  config.workspaces.spacenix = {
    enable = true;
    root = "personal";
    repos = [
      {
        url = "github:mdavezac/spacevim.nix";
        settings.user.email = config.emails.github;
        exclude = ["/.local"];
        destination = ".";
      }
    ];
    envrc = [
      ''
        export LAZY_NIX_ROOT=$PWD/.local/lazynix/
        use flake
      ''
    ];
  };
}
