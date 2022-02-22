{
  description = "Tripping Avenger's environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
        languages.python = true;
        layers.testing.enable = false;
        treesitter-languages = [ "json" "toml" "yaml" "graphql" "dockerfile" "bash" "make" ];
        formatters.black = pkgs.lib.mkForce {
          exe = "black";
          args = [ "--config" "./twisto/pyproject.toml" "-q" "-" ];
          filetype = "python";
          enable = true;
        };
        formatters.isort = pkgs.lib.mkForce {
          exe = "isort";
          args = [ "--settings-file" "./twisto/pyproject.toml" "-" ];
          filetype = "python";
          enable = true;
        };
        linters."diagnostics.mypy" = {
          exe = "mypy";
          enable = true;
          timeout = 10000;
        };
        background = "dark";
        colorscheme = "zenbones";
        init.lua = ''
          vim.g.monochrome_style = "subtle";
        '';
        post.vim = ''
          " highlight Folded guibg=#222222 guifg=#555555 gui=italic
          autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'python=python']
          let test#python#djangotest#executable = "python twisto/manage.py test"
        '';
        dash.python = [ "Django" ];
        dash.dockerfile = [ "Docker" ];
        plugins.start = [ pkgs.vimPlugins.vim-markdown ];
        textwidth = 120;
        which-key.bindings = [
          {
            key = "<leader>gd";
            command = "<CMD>DiffviewOpen origin/master...HEAD<CR>";
            description = "Diff current branch";
          }
        ];
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
          nvim = inputs.spacenix.wrapper.${system} configuration;
          cmd = ''
            rpc=$PRJ_DATA_DIR/nvim.rpc
            [ -e $rpc ] && ${pkgs.neovim-remote}/bin/nvr --servername $rpc -s $@ || ${nvim}/bin/nvim $@
          '';
        in
        pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          devshell.packages = [ nvim ];
          commands = builtins.map (x: { name = x; command = cmd; }) [ "vim" "vi" ];
          env =
            let
              editor = "${pkgs.neovim-remote}/bin/nvr --servername $PRJ_DATA_DIR/nvim.rpc -cc split --remote-wait -s $@";
            in
            [{ name = "GIT_EDITOR"; value = editor; } { name = "EDITOR"; value = editor; }];
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
