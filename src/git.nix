{ config, pkgs, lib, ... }:
let
  machine = import ../machine.nix;
  email = (import ../projects/lib/emails.nix).github;
in {
  home.packages = [
    pkgs.pre-commit pkgs.tig
    # pkgs.pinentry_mac
  ];

  programs.gh = {
    enable = true;
    editor = "nvim";
    gitProtocol = "https";
    aliases = {
      co = "pr checkout";
      pv = "pr view -w";
    };
  };
  programs.fish.interactiveShellInit = ''
    ${pkgs.gitAndTools.gh}/bin/gh completion --shell fish | source
  '';

  programs.git = {
    enable = true;
    userName = "Mayeul d'Avezac";
    userEmail = email;
    extraConfig = {
      core.autoclrf = "input";
      color.ui = true;
      apply.whitespace = "nowarn";
      branch.autosetupmerge = true;
      push.default = "upstream";
      advice.statusHints = false;
      format.pretty =
        "format:%C(blue)%ad%Creset %C(yellow)%h%C(green)%d%Creset %C(blue)%s %C(magenta) [%an]%Creset";
      http.sslcainfo = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      ghi.token = machine.github_token;
      pull.rebase = false;
      credential.helper="cache --timeout=960000";
    };
    signing = {
      key = email;
      signByDefault = false;
    };
    ignores = lib.splitString "\n" (builtins.readFile ../files/gitignore);
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        syntax-theme = "TwoDark";
        side-by-side = true;
      };
    };
  };

  programs.gpg.enable = false;
  services.gpg-agent.enable = false;
  services.gpg-agent.pinentryFlavor = "tty";

  home.sessionVariables.COLORTERM = "truecolor";
}
