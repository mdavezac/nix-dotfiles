super: self:
let
  pyrepl = pkgs: python:
    python.pkgs.buildPythonPackage rec {
      pname = "pyrepl";
      version = "0.9.0";

      src = python.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "0xd7h7k5cg9gd8nkqdykzkxmfasg8wwxcrmrpdqyh0jm9grp0999";
      };

      doCheck = false;

      meta = with pkgs.stdenv.lib; {
        homepage = "http://bitbucket.org/pypy/pyrepl/";
        license = "MIT X11 style";
        description = "A library for building flexible command line interfaces";
      };
    };

  fancycompleter = pkgs: python:
    python.pkgs.buildPythonPackage {
      name = "fancycompleter-0.9.1";
      src = pkgs.fetchurl {
        url =
          "https://files.pythonhosted.org/packages/a9/95/649d135442d8ecf8af5c7e235550c628056423c96c4bc6787348bdae9248/fancycompleter-0.9.1.tar.gz";
        sha256 =
          "09e0feb8ae242abdfd7ef2ba55069a46f011814a80fe5476be48f51b00247272";
      };

      doCheck = false;
      propagatedBuildInputs = [ (pyrepl pkgs python) ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pdbpp/fancycompleter";
        license = licenses.bsdOriginal;
        description = "colorful TAB completion for Python prompt";
      };
    };

  wmctrl = pkgs: python:
    python.pkgs.buildPythonPackage rec {
      pname = "wmctrl";
      version = "0.3";

      src = python.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "04wacb7lj7rbpx5q5cnb19n9k4w85szdfa8xwfv6chsmq5dgc1nq";
      };

      doCheck = false;
      meta = with pkgs.stdenv.lib; {
        homepage = "http://bitbucket.org/antocuni/wmctrl";
        license = licenses.bsdOriginal;
        description = "A tool to programmatically control windows inside X";
      };
    };

  pdbpp = pkgs: python:
    python.pkgs.buildPythonPackage rec {
      pname = "pdbpp";
      version = "0.10.2";

      src = python.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "1f2ysli7vka2drpw0p7rzqksr9cailrdh1977vffrq06a06j5zvk";
      };

      doCheck = false;
      propagatedBuildInputs = [
        (fancycompleter pkgs python)
        (wmctrl pkgs python)
        python.pkgs.pygments
        python.pkgs.six
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/antocuni/pdb";
        license = licenses.bsdOriginal;
        description = "pdb++, a drop-in replacement for pdb";
      };
    };
in {
  pdbpp37 = pdbpp super.pkgs super.python37;
  pdbpp38 = pdbpp super.pkgs super.python38;
}
