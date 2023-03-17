{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.fd pkgs.ripgrep];

  programs.skim = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f";
    fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
    fileWidgetOptions = ["--preview '${pkgs.bat}/bin/bat --color=always {}'"];
  };
  programs.fish = {
    interactiveShellInit = ''
      source ${pkgs.skim}/share/skim/key-bindings.fish
      skim_key_bindings
    '';
    functions.skim-issues = ''
      set --local preview  "env CLICOLOR_FORCE=1 gh issue view (echo {} | cut -d\t -f1)"
      set --local issue (
        sk --ansi -c "gh issue list" --preview $preview | cut -d\t -f1
      )
      gh issue view $issue
    '';
    functions.skim-edit = ''
      nvim (sk --ansi -c "fd --type f -H" --preview "bat --color=always {}")
    '';
  };

  programs.bat = {
    enable = true;
    config = {theme = "TwoDark";};
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    settings.verbs = [
      {
        invocation = "edit";
        shortcut = "e";
        execution = "nvim {file}";
      }
    ];
  };
}
