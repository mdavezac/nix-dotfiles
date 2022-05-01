{ config, lib, ... }:
let
  git_options = {
    url = lib.mkOption {
      type = lib.types.str;
      description = ''
        Repository to clone.
      '';
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of files to exclude";
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''Extra settings associated with the repo'';
    };
    destination = lib.mkOption {
      type = lib.types.str;
      default = ".";
      description = "Subdirectory where to clone repo.";
    };
  };

  workspace_options = {
    root = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = ''
        Root directory for the workspace.
        The workspace will be hosted under ~/<root>/<workspace name>/.

        Defaults to nill, i.e. to the home directory.
      '';
    };
    file = lib.mkOption {
      description = "Add files to project root. See `home.file`";
      type = lib.types.attrs;
      default = { };
    };
    enable = lib.mkOption {
      description = "Whether to enable a project";
      type = lib.types.bool;
      default = true;
    };
    repos = lib.mkOption {
      description = "List of repositories to clone";
      type = lib.types.listOf (lib.types.submodule { options = git_options; });
      default = [ ];
    };
    envrc = lib.mkOption {
      description = "List of commands to append to envrc";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    python = lib.mkOption {
      description = "Options related to python";
      type = lib.types.submodule {
        options.enable = lib.mkOption {
          description = "Enable adding python";
          type = lib.types.bool;
          default = false;
        };
        options.version = lib.mkOption {
          description = "Python version";
          type = lib.types.str;
          default = "3.10";
        };
        options.packager = lib.mkOption {
          description = "Python packaging framework";
          type = lib.types.choices [ null "poetry" ];
          default = null;
        };
      };
      default = { };
    };
  };

  internal_options = {
    root = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = ''
        Root directory for the workspace.
        The workspace will be hosted under ~/<root>/<workspace name>/.

        Defaults to nill, i.e. to the home directory.
      '';
    };
    file = lib.mkOption {
      description = "Add files to project root. See `home.file`";
      type = lib.types.attrs;
      default = { };
    };
    enable = lib.mkOption {
      description = "Whether to enable a project";
      type = lib.types.bool;
      default = true;
    };
    envrc = lib.mkOption {
      description = "List of commands to append to envrc";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
in
{
  options.workspaces = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = workspace_options;
    });
    description = "Each attribute is a different project.";
    default = { };
  };
  options._workspaces = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = internal_options;
    });
    description = "Each attribute is a different project.";
    internal = true;
    default = { };
  };
  config._workspaces = lib.mapAttrs
    (name: cfg: { inherit (cfg) enable file envrc root; })
    config.workspaces;
}
