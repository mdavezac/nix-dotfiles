{
  description = "Tripping Avenger's environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-21.05-darwin";

    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";

    ip4r.url = "github:RhodiumToad/ip4r/2.4.1";
    ip4r.flake = false;
  };

  outputs = inputs@{ self, devshell, nixpkgs, ... }:
    let
      ip4rMaker = { stdenv, postgresql, ip4r-src, ... }: stdenv.mkDerivation rec {
        name = "ip4r";
        version = "2.4.1";
        buildInputs = [ postgresql ];
        src = ip4r-src;
        postConfigure = ''
          # ip4r' build system assumes it is being installed to the same place as postgresql, and looks
          # for the postgres binary relative to $PREFIX. We gently support this system using an illusion.
          mkdir -p $out/bin
          ln -s ${postgresql}/bin/postgres $out/bin/postgres
        '';
        buildPhase = ''
          make all
        '';
        installPhase = ''
          make install \
            datadir=$out/share/postgresql \
            pkglibdir=$out/lib \
            bindir=$out/bin \
            docdir=$out/share/doc \
            includedir_server=$out/include/server
        '';
        postInstall = ''
          # Teardown the illusory postgres used for building; see postConfigure.
          rm $out/bin/postgres
        '';
      };

      stable = inputs.nixpkgs-stable.legacyPackages.x86_64-darwin;
      pkgs = import nixpkgs {
        system = "x86_64-darwin";
        config.allowUnfree = true;
        overlays = [
          devshell.overlay
          (self: super: rec {
            python38 = stable.python38;
            poetry = stable.poetry;
            mypy = stable.mypy;
            black = stable.black;
            flake8 = stable.flake8;
            postgresql = stable.postgresql;
            ip4r = ip4rMaker {
              inherit (stable) stdenv postgresql;
              ip4r-src = inputs.ip4r;
            };
            mypostgresql = postgresql.withPackages (p: [ p.postgis ip4r ]);
            redis = stable.redis;
            postgis = stable.postgis;
            gdal = stable.gdal;
            geos = stable.geos;
            cairo = stable.cairo;
            pango = stable.pango;
            glib = stable.glib;
            fontconfig = stable.fontconfig;
            graphviz = stable.graphviz;
            python38Packages.pex = stable.python38Packages.pex;
          })
        ];
      };
    in
    {
      devShell.x86_64-darwin = pkgs.devshell.mkShell {
        imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
      };
      apps.repl.x86_64-darwin = inputs.flake-utils.lib.mkApp {
        drv = pkgs.writeShellScriptBin "repl" ''
            confnix=$(mktemp)
          echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
          trap "rm $confnix" EXIT
          nix repl $confnix
        '';
      };
    };
}

