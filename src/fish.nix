{ config, pkgs, lib, ... }: {
  home.packages = [ pkgs.fish-foreign-env ];
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "${pkgs.bat}/bin/bat";
      vi = "nvim";
      vim = "nvim";
      tmux = "${pkgs.direnv}/bin/direnv exec / ${pkgs.tmux}/bin/tmux";
      ctags = "${pkgs.universal-ctags}/bin/ctags";
      grep = "${pkgs.ripgrep}/bin/rg";
      clang-format = "/usr/local/opt/llvm/bin/clang-format";
      clang-tidy = "/usr/local/opt/llvm/bin/clang-tidy";
    };
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish | source

      set -U fish_user_path /etc/profiles/per-user/mdavezac/bin

      ${pkgs.python3Packages.pip}/bin/pip completion --fish | source
      fenv source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.command-not-found.enable = true;
}
