{ config, lib, ... }:
let
  workspace_root = name: cfg: cfg.root + "/" + name;
  workspace_files = workspace_name: cfg: lib.mapAttrs'
    (name: value:
      lib.nameValuePair ((workspace_root workspace_name cfg) + "/" + name) value)
    cfg.file;
  active_workspaces = cfg: lib.filterAttrs (k: v: v.enable) cfg;
in
{
  config.home.file = lib.mkMerge (
    lib.attrValues
      (builtins.mapAttrs workspace_files (active_workspaces config._workspaces))
  );
}
