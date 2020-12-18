{ pkgs ? import <nixpkgs>, ... }:
pkgs.stdenv.mkDerivation {
  name = "space-vim_src";
  src = pkgs.fetchFromGitHub {
    owner = "liuchengxu";
    repo = "space-vim";
    rev = "b7cb35ed17e7c215964614e6694b10eae62949e3";
    sha256 = "0iqbxgvpirwpz7xqnxx3x3gvr5icq0wry7vc4mmb5qfkvz0vkmw1";
  };
  patchPhase = ''
        substituteInPlace init.vim --replace \$HOME.\'/.space-vim\' \'$out\'
        substituteInPlace init.vim --replace \$HOME/.space-vim $out
        substituteInPlace core/autoload/spacevim.vim \
        	--replace "let g:spacevim.info = g:spacevim.base. '/core/autoload/spacevim/info.vim'" \
    		"let g:spacevim.info = \$HOME . '/.spacevim.info.vim'"
        substituteInPlace layers/layers.py \
            --replace "~/.space-vim/core/autoload/spacevim/info.vim" "~/.spacevim.info.vim"
      '';
  dontConfigure = true;
  dontBuild = true;
  postInstall = "cp -r * $out/";
}
