{
  config,
  lib,
  pkgs,
  ...
}: {
  config.workspaces.multiplexer = {
    enable = true;
    root = "personal";
    python.enable = false;
    envrc = [
      ''
        export PRJ_DATA_DIR=$PWD/.local/devshell/data
        export PRJ_ROOT=$PWD/.local/devshell

        mkdir -p $PRJ_DATA_DIR
        mkdir -p $PRJ_ROOT

        PATH_add .local/bin/

        flakedir=~/personal/dotfiles/new_projects/personal/multiplexer
        [ -e  .local/flake ] || ln -s $flakedir .local/flake
        watch_file $flakedir/flake.nix
        watch_file $flakedir/flake.lock
        use flake $flakedir

        use flake .
      ''
    ];
  };
}
