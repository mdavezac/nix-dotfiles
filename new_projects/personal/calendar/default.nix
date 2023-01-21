{ config
, lib
, pkgs
, ...
}: {
  config.workspaces.calendar = {
    root = "personal";
    enable = true;
    envrc = [
      ''
        mkdir -p .local
        [ -e .local/flake ] || ln -s ~/personal/dotfiles/new_projects/personal/calendar .local/flake
        source_env .local/flake/.envrc
        source_env .devenv.envrc
      ''
    ];
  };
}
