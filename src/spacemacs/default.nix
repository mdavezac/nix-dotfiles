{ config, pkgs, lib, ... }:
let
  sources = import ../../nix/sources.nix;
  spacemacs = pkgs.stdenv.mkDerivation {
    name = "Spacemacs";
    buildInputs = [ pkgs.emacs ];
    src = sources.spacemacs;
    buildPhase = ''
      ${pkgs.emacs}/bin/emacs --batch --eval '(byte-recompile-directory "." 0)'
    '';
    dontConfigure = true;
    installPhase = ''
      [ -e $out ] || mkdir -p $out
      cp -r * $out/
      cp -r .lock .projectile $out/
    '';
  };
in {
  programs.emacs = {
    enable = true;
    extraPackages = (e: [ e.vterm ]);
  };

  home.packages = [ pkgs.nodePackages.pyright ];
  home.file.".spacemacs".text = (builtins.readFile (pkgs.substituteAll {
    src = ./spacemacs.el;
    fish = "${pkgs.fish}/bin/fish";
  }));
  home.file.".spacemacs.env".source = ./spacemacs.env;
  home.activation.spacemacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rsync -r $VERBOSE_ARG ${spacemacs}/* $HOME/.emacs.d/
    $DRY_RUN_CMD rsync $VERBOSE_ARG ${spacemacs}/.lock $HOME/.emacs.d/
    $DRY_RUN_CMD rsync $VERBOSE_ARG ${spacemacs}/.projectile $HOME/.emacs.d/
    chmod -R u+wX $HOME/.emacs.d/core/templates
  '';
}
