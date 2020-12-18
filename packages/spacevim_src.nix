{ pkgs ? import <nixpkgs>, ... }:
pkgs.stdenv.mkDerivation {
  name = "spacevim_src";
  buildInputs = [ pkgs.neovim-unwrapped ];
  src = pkgs.fetchFromGitHub {
    owner = "SpaceVim";
    repo = "SpaceVim";
    rev = "v1.5.0";
    sha256 = "1xw4l262x7wzs1m65bddwqf3qx4254ykddsw3c3p844pb3mzqhh7";
  };
  patchPhase = ''
    substituteInPlace autoload/SpaceVim.vim \
        --replace "exe 'helptags ' . help" ""
    substituteInPlace autoload/Spacevim/custom.vim \
        --replace "getftime(local_conf) < getftime(local_conf_cache)" "0"
  '';
  buildPhase = ''
    ${pkgs.neovim-unwrapped}/bin/nvim -es -n -i shada NONE --headless \
        --cmd "helptags doc" --cmd qall
  '';
  dontConfigure = true;
  installPhase = ''
    [ -e $out ] || mkdir -p $out
    cp -r * $out/
  '';
}
