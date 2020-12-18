{ config, lib, pkgs, ... }:
let
  mkImperialProject = import ./lib/project.nix "imperial";
  emails = import ./lib/emails.nix;
in {
  imports = builtins.map mkImperialProject [ "fellowship" ];

  projects.imperial.fellowship = {
    enable = false;
    repos.cv = {
      url = "https://gitlab.com/mdavezac/cv.git";
      dest = "cv";
      settings.user.email = emails.gitlab;
    };
    nixshell.text = ''
      buildInputs = [ pandoc ];
    '';
    vim = ''
      set textwidth=88
      set colorcolumn=89
    '';
    vim-spell = ''
      FTE
    '';
  };
}
