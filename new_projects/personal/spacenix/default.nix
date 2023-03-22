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
        export XDG_CONFIG_HOME=$PWD/.local/config
        export XDG_DATA_HOME=$PWD/.local/data
        export XDG_STATE_HOME=$PWD/.local/state
        use flake
      ''
    ];
  };
}
