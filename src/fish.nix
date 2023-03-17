{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "${pkgs.bat}/bin/bat";
      tmux = "${pkgs.direnv}/bin/direnv exec / ${pkgs.tmux}/bin/tmux";
      ctags = "${pkgs.universal-ctags}/bin/ctags";
      grep = "${pkgs.ripgrep}/bin/rg";
      clang-format = "/usr/local/opt/llvm/bin/clang-format";
      clang-tidy = "/usr/local/opt/llvm/bin/clang-tidy";
      ls = "${pkgs.exa}/bin/exa --icons";
    };
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      fish_add_path $HOME/.nix-profile/bin
      fish_add_path /run/current-system/sw/bin/
      ${pkgs.python3Packages.pip}/bin/pip completion --fish | source
      source /Applications/Docker.app/Contents/Resources/etc/docker-compose.fish-completion
      source /Applications/Docker.app/Contents/Resources/etc/docker.fish-completion
    '';
    functions.__fish_describe_command = "";
    plugins = [
      {
        name = "fish-foreign-env";
        src = pkgs.foreign-fish;
      }
    ];
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
