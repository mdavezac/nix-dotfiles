{ config, pkgs, lib, ... }: {
  programs.fish = {
    enable = true;
    shellAliases = {
      issues = "${pkgs.gitAndTools.hub}/bin/hub browse -- issues";
      pulls = "${pkgs.gitAndTools.hub}/bin/hub browse -- pulls";
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
      # because liluball/nix-env keeps growing the path
      set -gx NIX_PATH (printf "%s\n" $NIX_PATH | uniq)

      set -U fish_user_path /etc/profiles/per-user/mdavezac/bin

      ${pkgs.python3Packages.pip}/bin/pip completion --fish | source
    '';
    plugins = [
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "cf99a2e6e8f4ba864e70cf286f609d2cd7645263";
          sha256 = "0170c7yy6givwd0nylqkdj7kds828a79jkw77qwi4zzvbby4yf51";
        };
      }
    ];
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
