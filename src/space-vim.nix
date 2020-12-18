pkgs: {
  home.file.".spacevim".source = ./spacevim.vim;
  programs.neovim = let mypkgs = import ../packages pkgs;
  in {
    enable = false;
    extraConfig = ''
      source ${mypkgs.space-vim_src}/init.vim
    '';
    extraPython3Packages = (ps: with ps; [ flake8 pynvim msgpack black ]);
    viAlias = true;
    vimAlias = true;
    withPython = false;
    withPython3 = true;
    withRuby = true;
  };
}
