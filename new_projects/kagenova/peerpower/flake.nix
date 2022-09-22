rec {
  description = "360Learning environment";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    spacenix.url = "/Users/mdavezac/personal/spacenix";
  };

  outputs = { self, flake-utils, devshell, nixpkgs, spacenix, mach-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        configuration.nvim = {
          layers.git.github = true;
          layers.debugger.enable = true;
          layers.neorg.enable = false;
          languages.markdown = true;
          languages.nix = true;
          languages.python = true;
          dash.python = [ "pandas" "numpy" ];
          treesitter-languages = [ "json" "toml" "yaml" "bash" "fish" ];
          colorscheme = "papercolor";
          post.vim = ''
            autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
          '';
          formatters.isort.exe = pkgs.lib.mkForce "isort";
          formatters.black.exe = pkgs.lib.mkForce "black";
          init.vim = ''
            function PythonModuleName()
                let relpath = fnamemodify(expand("%"), ":.:s?app/??")
                return substitute(substitute(relpath, ".py", "", ""), "\/", ".", "g")
            endfunction
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

          layers.terminal.repl.favored.python = pkgs.lib.mkForce "require('iron.fts.python').ipython";
        };
      in
      {
        devShells.default =
          let
            nvim_pkg = spacenix.lib."${system}".spacenix-wrapper configuration;
            nvim_mod = spacenix.modules."${system}".devshell nvim_pkg;
          in
          pkgs.devshell.mkShell {
            imports = [ nvim_mod ];
            commands = [
              { package = pkgs.awscli2; }
              { package = pkgs.aws-vault; }
              { package = pkgs.pass; }
              { package = pkgs.poetry; }
              { package = pkgs.pre-commit; }
              { package = pkgs.python310; }
            ];
          };
      });
}
