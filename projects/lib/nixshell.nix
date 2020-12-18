{
  isEnabled = config: !builtins.isNull config.text;
  file = { project, config, lib, pkgs, path }:
    let
      prjList = if builtins.isList project then project else [ project ];
      name = if config.shell == "mkShell" then
        ''name="'' + (lib.concatStringsSep "-" prjList) + ''";''
      else
        "";
      home = (import ../../machine.nix).home;
      text = config: name: ''
        { pkgs ? import <nixpkgs> {} }:

        with pkgs;

        ${config.shell} {
          ${name}
          ${
            builtins.replaceStrings [ "@path@" "@home@" ] [ path home ]
            config.text
          }
        }
      '';
      format = text:
        (pkgs.runCommand "shell.nix" { buildInputs = [ pkgs.nixfmt ]; }
          "${pkgs.nixfmt}/bin/nixfmt < ${
            pkgs.writeText "shell.nix" text
          } > $out");
    in (format (text config name));
}
