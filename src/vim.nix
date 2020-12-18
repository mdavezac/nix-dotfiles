mypkgs: pkgs: {
  home.files.".spacevim".source = ./spacevim.init;
  programs.neovim = {
    enable = true;
    extraConfig = ''
      source ${mypkgs.spacevim_src}/init.vim
    '';
    extraPythonPackages = (ps: with ps; [ flake8 pynvim ]);
  };
}
