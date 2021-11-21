{
  description = "Tripping Avenger's environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.05-darwin";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    ip4r.url = "github:RhodiumToad/ip4r/2.4.1";
    ip4r.flake = false;

    spacenix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = inputs@{ self, devshell, nixpkgs, ... }:
    let
      system = "x86_64-darwin";
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

      configuration.nvim = {
        languages.nix = true;
        layers.projects.enable = false;
        treesitter-languages = [ "json" "toml" "python" "yaml" "graphql" ];
        lsp-instances.pyright.cmd = [
          "${pkgs.nodePackages.pyright}/bin/pyright-langserver"
          "--stdio"
        ];
        formatters = {
          black = {
            exe = "black";
            args = [ "--config" "twisto/pyproject.toml" "-q" "-" ];
            filetype = "python";
            enable = true;
          };
          isort = {
            exe = "isort";
            args = [ "--settings-file" "./twisto/.isort.cfg" "-" ];
            filetype = "python";
            enable = true;
          };
        };
        colorscheme = "monochrome";
        init.lua = ''
            vim.g.monochrome_style = "subtle";
        '';
        post.vim = ''
            highlight Folded guibg=#222222 guifg=#555555 gui=italic
        '';
      };

      pkgs = import nixpkgs rec {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = [
          devshell.overlay
          (self: super: rec {
            ip4r = ip4rMaker {
              inherit (self) stdenv postgresql;
              ip4r-src = inputs.ip4r;
            };
            mypostgresql = self.postgresql.withPackages (p: [ p.postgis ip4r ]);
          })
        ];
      };
    in
    {
      devShell.${system} =
        let
          cmd = "${pkgs.neovim-remote}/bin/nvr --servername $PRJ_DATA_DIR/nvim.rpc -s $@";
          nvim = (inputs.spacenix.wrapper.${system} configuration);
        in
        pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          devshell.packages = [ nvim ];
          commands = builtins.map (x: { name = x; command = cmd;}) [ "vim" "vi" ];
        };
      apps.repl."${system}" = inputs.flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "repl" ''
            confnix=$(mktemp)
            echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
            trap "rm $confnix" EXIT
            nix repl $confnix
          '';
        };
    };
}
