{ lib, buildPythonPackage, fetchPypi, untokenize }:

buildPythonPackage rec {
  pname = "docformatter";
  version = "1.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1qx7kw52ylgwgcm34qgq5f1jqvq70rd67cipaz3wmk5yclv6dnyq";
  };

  doCheck = false;
  propagatedBuildInputs = [ untokenize ];

  meta = with lib; {
    homepage = "https://github.com/myint/docformatter";
    description = "Formats docstrings to follow PEP 257";
    license = licenses.mit;
  };
}
