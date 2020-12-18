{ pkgs ? import <nixpkgs> { } }: rec {
  space-vim_src = import ./space-vim_src.nix pkgs;
  spacevim_src = import ./spacevim_src.nix pkgs;
  untokenize = pkgs.callPackage ./untokenize.nix {
    buildPythonPackage = pkgs.python38Packages.buildPythonPackage;
    fetchPypi = pkgs.python38Packages.fetchPypi;
  };
  docformatter = pkgs.callPackage ./docformatter.nix {
    buildPythonPackage = pkgs.python38Packages.buildPythonPackage;
    fetchPypi = pkgs.python38Packages.fetchPypi;
    untokenize = untokenize;
  };
}
