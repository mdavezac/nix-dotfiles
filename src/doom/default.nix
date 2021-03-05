{ config, pkgs, lib, ... }:
let
  sources = import ../../nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  doom-emacs = pkgs.buildEnv {
    name = "doom-emacs";
    ignoreCollisions = true;
    paths = with pkgs; [
      ((emacsPackagesNgGen emacs).withPackages (e: [ e.vterm ]))
      (python37.withPackages (p: [ p.black p.pyflakes p.isort ]))
      bash
      coreutils
    ];
    pathsToLink = [ "/bin" "/Applications" "/share" ];
    extraOutputsToInstall = [ "Applications" ];
  };
in {
  programs.emacs = {
    enable = true;
    package = doom-emacs;
  };
  programs.fish.functions = {
    vterm_prompt_end = "vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)";
    vterm_printf = ''
      if [ -n "$TMUX" ]
          # tell tmux to pass the escape sequences through
          printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
      else if string match -q -- "screen*" "$TERM"
          # GNU screen (screen, screen-256color, screen-256color-bce)
          printf "\eP\e]%s\007\e\\" "$argv"
      else
          printf "\e]%s\e\\" "$argv"
      end
    '';
  };
  home.packages = [ pkgs.nodePackages.pyright ];
  home.file.".doom.d/init.el" = {
    source = ./init.el;
    onChange = ''
      PATH=${doom-emacs}/bin:${pkgs.git}/bin:${pkgs.fd}/bin:${pkgs.direnv}/bin bash -l ~/.emacs.d/bin/doom sync
    '';
  };
  home.file.".doom.d/packages.el" = {
    source = ./packages.el;
    onChange = ''
      PATH=${doom-emacs}/bin:${pkgs.git}/bin:${pkgs.fd}/bin:${pkgs.direnv}/bin bash -l ~/.emacs.d/bin/doom sync
    '';
  };
  home.file.".doom.d/config.el".text = (builtins.readFile (pkgs.substituteAll {
    src = ./config.el;
    fish = "${pkgs.fish}/bin/fish";
    nixfmt = "${pkgs.nixfmt}/bin/nixfmt";
    git = "${pkgs.git}/bin/git";
    roslyn = "${pkgs.omnisharp-roslyn}/bin/omnisharp";
  }));

  home.activation.doom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rsync -r $VERBOSE_ARG ${sources.doom-emacs}/* $HOME/.emacs.d/
    chmod -R u+wX $HOME/.emacs.d/
  '';
}
