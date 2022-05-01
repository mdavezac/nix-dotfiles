{ config, lib, pkgs, ... }:
let
  envrc_lines = workspaces: lib.mapAttrs
    (name: cfg: { envrc = [ ''source ${git_envrc_lib}'' ] ++ ((git_repos name cfg)); })
    (active_workspaces workspaces);

  active_workspaces = cfg: lib.filterAttrs (k: v: v.enable) cfg;

  add_repos_files = local_path: file_func: workspaces:
    builtins.mapAttrs
      (wname: wcfg: {
        file = builtins.listToAttrs (
          builtins.map
            (rcfg: {
              name = "${rcfg.destination}/${local_path}";
              value = (file_func rcfg);
            })
            wcfg.repos
        );
      })
      (active_workspaces workspaces);

  git_repos = name: cfg: builtins.map git_repo cfg.repos;
  git_repo = { url, destination, ... }:
    ''
      clone_git_repo "${url}" ${destination} origin
    '';

  git_envrc_lib = pkgs.writeTextFile {
    name = "git_envrc_lib.sh";
    text = ''
      function clone_git_repo () {
          local url=$1
          local destination=$2
          local origin=$3
          local git=${pkgs.git}/bin/git

          [ -e "$destination/.git/HEAD" ] && return 1;

          tmpdir=$(mktemp -d)
          mkdir -p $tmpdir
          trap "rm -rf $tmpdir" EXIT

          url=''${url/#github:/https:\/\/github.com\/}
          url=''${url/#ssh_github:/git@github.com:}
          url=''${url/#gitlab:/https:\/\/gitlab.com\/}
          url=''${url/#ssh_gitlab:/git@gitlab.com:}

          $git clone --no-checkout --origin=$origin $url $tmpdir
          mkdir -p $destination/.git/
          rm $tmpdir/.git/info/exclude
          rmdir $tmpdir/.git/info
          rm -r $tmpdir/.git/hooks/*
          mv $tmpdir/.git/* $destination/.git/

          $git -C $destination reset --hard HEAD
          $git -C $destination config --local include.path .git/nix/config
      }
    '';
  };
  git_config_extras_file = cfg: { text = lib.generators.toGitINI cfg.settings; };
  git_exclude = cfg: { text = builtins.concatStringsSep "\n" cfg.exclude; };
in
{
  config._workspaces = lib.mkMerge [
    (envrc_lines config.workspaces)
    (add_repos_files ".git/nix/config" git_config_extras_file config.workspaces)
    (add_repos_files ".git/info/exclude" git_exclude config.workspaces)
  ];
}
