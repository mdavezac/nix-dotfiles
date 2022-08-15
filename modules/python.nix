{ config, lib, pkgs, ... }:
let
  workspace_root = name: cfg: cfg.root + "/" + name;
  poetry_envrc_lib = name: cfg: pkgs.writeTextFile {
    name = "poetry_envrc_lib.sh";
    text = ''
      layout_poetry() {
        if [[ ! -f ~/${workspace_root name cfg}/${cfg.python.subdirectory}/pyproject.toml ]]; then
          log_error 'No pyproject.toml found. Use `poetry new` or `poetry init` to create one first.'
          exit 0
        fi

        local VENV=$(poetry env use --quiet python$1 && poetry env info -p)
        if [[ -z $VENV || ! -d $VENV/bin ]]; then
          echo 'No poetry virtual environment found. Use `poetry install` to create one first.'
          exit 0
        fi

        export VIRTUAL_ENV=$VENV
        export POETRY_ACTIVE=1
        PATH_add "$VENV/bin"
      }
    '';
  };

  poetry_setup = workspaces: lib.mapAttrs
    (name: cfg: {
      envrc = [
        ''
          source ${poetry_envrc_lib name cfg}
          export POETRY_VIRTUALENVS_PATH=$PWD/.local/poetry/venvs
          layout poetry ${cfg.python.version}
        ''
      ];
      devshell.packages = [ "poetry" ];
    })
    (lib.filterAttrs (k: v: v.python.enable && v.python.packager == "poetry") workspaces);

  pip_setup = workspaces: lib.mapAttrs
    (name: cfg: {
      envrc = [
        ''
          layout python python${cfg.python.version}
        ''
      ];
      devshell.packages = [ "pip" ];
    })
    (lib.filterAttrs (k: v: v.python.enable && v.python.packager == "pip") workspaces);

  python_setup = workspaces: lib.mapAttrs
    (name: cfg: {
      devshell.packages =
        let
          version = builtins.replaceStrings [ "." ] [ "" ] cfg.python.version;
        in
        [ "python${version}" ];
    })
    (lib.filterAttrs (k: v: v.python.enable) workspaces);
in
{
  config._workspaces = lib.mkMerge [
    (poetry_setup config.workspaces)
    (pip_setup config.workspaces)
    (python_setup config.workspaces)
  ];
}
