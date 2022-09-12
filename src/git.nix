{ config, pkgs, lib, ... }:
let
  email = (import ../projects/lib/emails.nix).github;
in
{
  home.packages = [ pkgs.tig pkgs.cacert pkgs.pinentry_mac ];

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases = {
        co = "pr checkout";
        pv = "pr view -w";
        st = "pr status";
        mypr = "pr list -S author:mdavezac";
      };
    };
  };
  home.file.".config/fish/completions/gh.fish".source =
    pkgs.runCommand
      "fish-completion"
      { }
      "${pkgs.gitAndTools.gh}/bin/gh completion -s fish > $out";

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
      pull.rebase = false;
      init.defaultBranch = "main";
    };
    aliases.children = "!${pkgs.bash}/bin/bash -c 'c=\${1:-HEAD}; set -- $(git rev-list --all --not \"$c\"^@ --children | grep $(git rev-parse \"$c\") ); shift; echo $1' -";
    signing = {
      key = email;
      signByDefault = true;
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

  programs.gpg.enable = true;

  home.sessionVariables.COLORTERM = "truecolor";
}
