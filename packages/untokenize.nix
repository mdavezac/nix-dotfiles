{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "untokenize";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "18ipdy9dlpqzpnfcc9ginyl0xq0b7rzvxwbjm9gbpd7gp2xxnr9q";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/myint/untokenize";
    description = ''
      Transforms tokens into original source code (while preserving whitespace)
    '';
    license = licenses.mit;
  };
}
