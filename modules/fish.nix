{
  config,
  lib,
  pkgs,
  ...
}: let
  fish_history = workspaces:
    lib.mapAttrs
    (name: cfg: let
      session_name = builtins.replaceStrings ["-" " " "."] ["_" "_" "_"] name;
      root_name =
        if (builtins.isNull cfg.root)
        then ""
        else
          (
            (builtins.replaceStrings ["/"] ["_"] cfg.root) + "_"
          );
    in {
      envrc = [
        ''
          export fish_history=${root_name}${session_name}
        ''
      ];
    })
    (lib.filterAttrs (k: v: v.fish.enable && v.fish.history) workspaces);
  fish_tmux_session = workspaces:
    lib.mapAttrs
    (name: cfg: let
      session_name = builtins.replaceStrings ["-" " " "."] ["-" "-" "-"] name;
      root_name =
        if (builtins.isNull cfg.root)
        then ""
        else
          (
            (builtins.replaceStrings ["/"] ["_"] cfg.root) + "-"
          );
    in {
      envrc = [
        ''
          export TMUX_SESSION_NAME=${root_name}${session_name}
        ''
      ];
    })
    (lib.filterAttrs (k: v: v.fish.enable && v.fish.tmux) workspaces);
  fish_zellij_session = workspaces:
    lib.mapAttrs
    (name: cfg: let
      session_name = builtins.replaceStrings ["-" " " "."] ["-" "-" "-"] name;
      root_name =
        if (builtins.isNull cfg.root)
        then ""
        else
          (
            (builtins.replaceStrings ["/"] ["_"] cfg.root) + "-"
          );
    in {
      envrc = [
        ''
          export AUTO_ZELLIJ_SESSION=${root_name}${session_name}
        ''
      ];
    })
    (lib.filterAttrs (k: v: v.fish.enable && v.fish.zellij) workspaces);
in {
  config._workspaces = lib.mkMerge [
    (fish_history config.workspaces)
    (fish_tmux_session config.workspaces)
    (fish_zellij_session config.workspaces)
  ];
}
