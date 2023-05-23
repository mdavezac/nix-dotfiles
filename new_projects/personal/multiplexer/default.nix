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

        use flake .
      ''
    ];
  };
}
