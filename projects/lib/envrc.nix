{ project, config, lib, pkgs }:
let
  emptyAttrs = attrs: builtins.length (builtins.attrNames attrs) != 0;
  leftOrRight = left: right: if builtins.isNull left then right else left;
  cloner = name:
    { url, dest, origin, ignore, settings }:
    let
      destination = leftOrRight dest name;
      createSettings = settings:
        pkgs.writeTextFile {
          name = "gitconfig";
          text = lib.generators.toGitINI settings;
        };
    in ''
      [ -d "${destination}/.git" ] || cloner ${url} ${destination} ${origin}
    '' + lib.optionalString (emptyAttrs settings)
    "git_settings ${createSettings settings} ${destination}\n"
    + lib.optionalString (lib.stringLength ignore > 0) ''
      mkdir -p ${destination}/.git/info
      cat > ${destination}/.git/info/exclude <<EOF
      ${ignore}
      EOF
    '';
  cloners = repos:
    (builtins.concatStringsSep "\n" (lib.mapAttrsToList cloner repos));
  isNixshellEnabled = (import ./nixshell.nix).isEnabled;

in (cloners config.repos) + ''
  export fish_history="${builtins.concatStringsSep "" project}"
  export TMUX_SESSION_NAME=${builtins.concatStringsSep "-" project}
'' + lib.optionalString (isNixshellEnabled config.nixshell) ''
  eval "$(lorri direnv)"
  fixnix
'' + lib.optionalString (lib.stringLength config.vim > 0) ''
  nvim_setup
'' + lib.optionalString (lib.stringLength config.ipython > 0) ''
  export IPYTHONDIR=$(pwd)/.local/ipython
'' + config.extraEnvrc
