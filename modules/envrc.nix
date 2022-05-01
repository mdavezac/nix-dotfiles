{ config, lib, pkgs, ... }:
let
  add_workspace_files = key_func: file_func: lib.mapAttrs'
    (wname: wcfg: lib.nameValuePair (key_func wname wcfg) (file_func wname wcfg))
    (active_workspaces config.workspaces);
  add_repos_files = local_path: file_func:
    builtins.listToAttrs (
      builtins.concatLists (
        lib.mapAttrsToList
          (workspace_name: workspace:
            builtins.map
              (repo: {
                name = root_file_path local_path workspace_name workspace;
                value = file_func repo;
              })
              workspace.repos
          )
          (active_workspaces config.workspaces)
      )
    );
  active_workspaces = cfg: lib.filterAttrs (k: v: v.enable) cfg;

  root_path = name: cfg: cfg.root + "/" + name + "/";
  root_file_path = filepath: workspace_name: cfg:
    (root_path workspace_name cfg) + filepath;

  envrc_file = wname: wcfg:
    let
      _wcfg = builtins.getAttr wname config._workspaces;
    in
    { text = builtins.concatStringsSep "\n\n" _wcfg.envrc; };

  git_config_extras_file = cfg: { text = lib.generators.toGitINI cfg.settings; };
  git_exclude = cfg: { text = builtins.concatStringsSep "\n" cfg.exclude; };
in
{
  config.home.file = (add_workspace_files (root_file_path ".envrc") envrc_file);
  /* // (add_repos_files ".git/nix/config" git_config_extras_file) */
  /* // (add_repos_files ".git/info/exclude" git_exclude); */
}
