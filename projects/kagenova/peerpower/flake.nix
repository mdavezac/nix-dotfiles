rec {
  description = "360Learning environment";
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = {
    self,
    flake-utils,
    devshell,
    nixpkgs,
    spacenix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        imports = [
          (import "${devshell}/extra/language/c.nix")
          spacenix.modules.${system}.prepackaged
          spacenix.modules.devshell
        ];
        spacenix = {
          layers.git.github = true;
          layers.debugger.enable = true;
          layers.neorg.enable = false;
          layers.completion.sources.other = [
            {
              name = "buffer";
              group_index = 3;
              priority = 100;
            }
            {
              name = "path";
              group_index = 2;
              priority = 50;
            }
            {
              name = "emoji";
              group_index = 2;
              priority = 50;
            }
          ];
          layers.completion.sources."/" = [{name = "buffer";}];
          layers.completion.sources.":" = [{name = "cmdline";}];
          languages.markdown = true;
          languages.nix = true;
          languages.python = true;
          dash.python = ["pandas" "numpy"];
          treesitter-languages = ["json" "toml" "yaml" "bash" "fish"];
          colorscheme = "bluloco";
          cursorline = true;
          telescope-theme = "ivy";
          formatters.isort.exe = "isort";
          formatters.black.exe = "black";
          layers.terminal.repl.repl-open-cmd = ''
            require('iron.view').split.vertical.botright(
                "50%", { number = false, relativenumber = false }
            )
          '';
          init.vim = ''
            function PythonModuleName()
                let relpath = fnamemodify(expand("%"), ":.:s")
                return substitute(substitute(relpath, ".py", "", ""), "\/", ".", "g")
            endfunction

            au BufRead,BufNewFile *.jsonl  set filetype=json
          '';
          which-key.bindings = [
            {
              key = "<leader>gd";
              command = "<CMD>DiffviewOpen origin/develop...HEAD<CR>";
              description = "Diff current branch";
            }
            {
              key = "<leader>fm";
              command = "<CMD>let @\\\" = PythonModuleName()<CR>";
              description = "Filename as python module";
            }
          ];

          layers.terminal.repl.repls.python = "require('iron.fts.python').ipython";
        };
        language.c.libraries = ["openssl.out"];
        env = [
          {
            name = "LDFLAGS";
            eval = "-L$DEVSHELL_DIR/lib";
          }
          {
            name = "DYLD_FALLBACK_LIBRARY_PATH";
            prefix = "$DEVSHELL_DIR/lib";
          }
        ];
        commands = [
          {package = pkgs.awscli2;}
          {package = pkgs.aws-vault;}
          {package = pkgs.pass;}
          {package = pkgs.poetry;}
          {package = pkgs.pre-commit;}
          {package = pkgs.python310;}
          {package = pkgs.google-cloud-sdk;}
          {package = pkgs.pandoc;}
          {package = pkgs.texlive.combined.scheme-full;}
          {package = pkgs.postgresql;}
          {package = pkgs.mysql;}
        ];
      };
    });
}
